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

require File.join(File.dirname(__FILE__), "machine_tag", "machine_tag_base.rb")
require File.join(File.dirname(__FILE__), "machine_tag", "machine_tag_rightscale.rb")
require File.join(File.dirname(__FILE__), "machine_tag", "machine_tag_vagrant.rb")

class Chef
  module MachineTag

    # Factory method for instantiating the correct machine tag class based on
    # `node['cloud']['provider']` value. This value will be set to 'vagrant' on
    # Vagrant environments.
    #
    # @param node [Chef::Node] the chef node
    #
    # @return [Chef::MachineTagVagrant, Chef::MachineTagRightscale] the instance corresponding to
    #   the machine tag environment
    #
    def self.factory(node)
      begin
        require 'machine_tag'
      rescue LoadError => e
        raise e, "'machine_tag' gem is not installed!" +
          " Run the 'machine_tag::default' recipe first to install this gem."
      end

      if node['cloud'].nil? || node['cloud']['provider'].nil?
        raise "ERROR: could not detect a supported machine tag environment."
      elsif node['cloud']['provider'] == 'vagrant'
        # This is a Vagrant environment
        hostname, cache_dir = vagrant_params_from_node(node)
        Chef::MachineTagVagrant.new(hostname, cache_dir)
      else
        # This is a RightScale environment
        Chef::MachineTagRightscale.new
      end
    end

    private

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
      arg_error("node['machine_tag'] hash not defined.") unless node.has_key?('machine_tag')

      # Verify cache_dir
      unless node['machine_tag']['vagrant_tag_cache_dir']
        arg_error("node['machine_tag']['vagrant_tag_cache_dir'] not defined.")
      end

      return node['hostname'], node['machine_tag']['vagrant_tag_cache_dir']
    end

    # Raises an {#ArgumentError} with a custom error message.
    #
    # @param message [String] the error message
    #
    def self.arg_error(message)
      raise ArgumentError, message + " Please see the README file in the 'machine_tag' cookbook."
    end

  end

  module MachineTagHelper
    # Return the list of tags for all server that match the query. An optional
    # +:required_tags+ key can be passed into the `options` hash which will requery
    # for the tags until they become available in one of the servers.
    #
    # @param node [Chef::Node] the chef node
    # @param query [Array<String>] the list of tags to be queried
    # @param options [Hash{String => String, Integer}] the optional parameters for queries
    #
    # @option options [Array] :required_tags the tags required to available in the query result
    # @option options [Integer] :query_timeout (2) the timeout value (in minutes) for the query.
    #
    def tag_search(node, query, options = {})
      Chef::MachineTag.factory(node).search(query, options)
    end

    # Returns a hash of all tags on the current server.
    #
    # @param node [Chef::Node] the chef node
    #
    def tag_list(node)
      Chef::MachineTag.factory(node).list
    end
  end

end
