#
# Cookbook Name:: machine_tag
# Library:: machine_tag_helper
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative 'machine_tag_rightscale'
require_relative 'machine_tag_rl10'
require_relative 'machine_tag_vagrant'
require 'chef/sugar'

include Chef::Sugar::Docker

require 'chef/mixin/shell_out'

class Chef
  module MachineTag
    extend Chef::Mixin::ShellOut

    # Factory method for instantiating the correct machine tag class based on
    # `node['cloud']['provider']` value. This value will be set to `'vagrant'` on
    # Vagrant environments.
    #
    # @param node [Chef::Node] the chef node
    #
    # @return [Chef::MachineTagBase] the instance corresponding to
    #   the machine tag environment
    #
    def self.factory(node)
      begin
        require 'machine_tag'
      rescue LoadError => e
        raise e, "'machine_tag' gem is not installed!" \
                 " Run the 'machine_tag::default' recipe first to install this gem."
      end

      if shell_out('which', 'rs_tag').exitstatus == 0
        # This is a RightScale environment
        Chef::MachineTagRightscale.new
      elsif shell_out('which', 'rightlink').exitstatus == 0 &&
            shell_out('rightlink', '-version').stdout =~ /^RightLink 10/
        # This is a RightLink 10 environment
        Chef::MachineTagRl10.new
      elsif ( node['cloud'] && node['cloud']['provider'] == 'vagrant' ) || docker?(node)
        # This is a Vagrant environment
        hostname, cache_dir = vagrant_params_from_node(node)
        Chef::MachineTagVagrant.new(hostname, cache_dir)
      else
        raise 'Could not detect a supported machine tag environment.'
      end
    end

    # Harvests Vagrant parameters from the chef node.
    #
    # @param node [Chef::Node] the chef node
    #
    # @raise [ArgumentError] if Vagrant parameters, namely hostname and machine_tag hash,
    #   are not found in the node
    #
    def self.vagrant_params_from_node(node)
      arg_error("node['hostname'] not defined.") unless node['hostname']

      # Verify machine_tag hash
      arg_error("node['machine_tag'] hash not defined.") unless node.key?('machine_tag')

      # Verify cache_dir
      unless node['machine_tag']['vagrant_tag_cache_dir']
        arg_error("node['machine_tag']['vagrant_tag_cache_dir'] not defined.")
      end

      [node['hostname'], node['machine_tag']['vagrant_tag_cache_dir']]
    end

    # Raises an `ArgumentError` with a custom error message.
    #
    # @param message [String] the error message
    #
    def self.arg_error(message)
      raise ArgumentError, message + " Please see the README file in the 'machine_tag' cookbook."
    end
  end

  module MachineTagHelper
    # Helper method that returns the list of tags for all server that match the query.
    # An optional `:required_tags` key can be passed into the `options` hash which will
    # re-query for the tags until they become available.
    #
    # @param node [Chef::Node] the chef node
    # @param query_tags [String, Array<String>] the tag or list of tags to be queried
    #
    # @option options [Array<String>] :required_tags the tags that should be found by the query.
    #   If the tags are not found at the time of the query, re-query until they are found or the timeout is reached
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Array<MachineTag::Set>] the array of all tags on the servers that matched the query tags
    #
    def self.tag_search(node, query_tags, options = {})
      Chef::MachineTag.factory(node).search(query_tags, options)
    end

    # Returns the list of tags for all servers that match the query.
    #
    # @see MachineTagHelper.tag_search
    #
    def tag_search(node, query_tags, options = {})
      MachineTagHelper.tag_search(node, query_tags, options)
    end

    # Helper method that returns a set of all tags on the current server.
    #
    # @param node [Chef::Node] the chef node
    #
    # @return [MachineTag::Set] the set of all tags on the server
    #
    def self.tag_list(node)
      Chef::MachineTag.factory(node).list
    end

    # Returns a set of all tags on the current server.
    #
    # @see MachineTagHelper.tag_list
    #
    def tag_list(node)
      MachineTagHelper.tag_list(node)
    end
  end
end
