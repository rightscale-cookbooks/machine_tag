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
  class MachineTag

    # Factory method for instantiating the correct machine tag class based on `node[:cloud][:provider]`
    # value. On vagrant environments, the node[:cloud][:provider] will be set to 'vagrant' when the
    # vagrant-ohai plugin is installed.
    def self.factory(node)
      if node[:cloud].nil? || node[:cloud][:provider].nil?
        raise "ERROR: could not detect a supported machine tag environment."
      elsif node[:cloud][:provider] == 'vagrant'
        box_name, cache_dir = vagrant_params_from_node(node)
        Chef::MachineTagVagrant.new(box_name, cache_dir)
      else
        Chef::MachineTagRightscale.new
      end
    end

    private

    # Use the factory method to create MachineTag class
    def initalize()
    end

    # harvest params from chef node with error checking
    def self.vagrant_params_from_node(node)
      # Verify box_name
      box_name = node['vagrant']['box_name']
      err_msg = "ERROR: node['vagrant']['box_name'] not defined. " + readme_info
      arg_error(err_msg) unless box_name

      # Veify machine_tag hash
      err_msg = "ERROR: node['machine_tag'] hash not defined. " + readme_info
      arg_error(err_msg) unless node.has_key?('machine_tag')

      # Vefiy cache_dir
      cache_dir = node['machine_tag']['vagrant_tag_cache_dir']
      err_msg = "ERROR: node['machine_tag']['vagrant_tag_cache_dir'] " +
                "not defined. " + readme_info
      arg_error(err_msg) unless cache_dir

      return box_name,cache_dir
    end

    def self.readme_info
      "Please see the README file in the 'machine_tag' cookbook."
    end

    def self.arg_error(message)
      raise ArgumentError.new(message)
    end

  end

  module MachineTagHelper
    def tag_search(node, query = nil, args = {})
      Chef::MachineTag.factory(node).search(query, args)
    end

    def tag_list(node)
      Chef::MachineTag.factory(node).list
    end
  end

end
