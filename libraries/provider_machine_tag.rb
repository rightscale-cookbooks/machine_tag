#
# Cookbook Name:: machine_tag
# Library:: provider_machine_tag
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

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'chef/provider'
require 'resource_machine_tag'
require 'machine_tag_helper.rb'

class Chef
  class Provider
    class MachineTag < Chef::Provider
      # Finds an existing `machine_tag` resource on the node based on `machine_tag` name
      # and loads the current resource with the attributes on the node.
      #
      # @return [Chef::Resource::MachineTag] the resource found in the node
      #
      def load_current_resource
        @current_resource = Chef::Resource::MachineTag.new(@new_resource.name)
        @tag_helper = get_helper(@run_context.node)
        @current_resource
      end

      # Creates a machine tag on the server.
      #
      def action_create
        status = @tag_helper.create(new_resource.name)
        Chef::Log.info "Created tag '#{new_resource.name}', Status: #{status}"
        new_resource.updated_by_last_action(true)
      end

      # Deletes a machine tag from the server.
      #
      def action_delete
        status = @tag_helper.delete(new_resource.name)
        Chef::Log.info "Deleted tag '#{new_resource.name}', Status: #{status}"
        new_resource.updated_by_last_action(true)
      end

      private

      # Gets the machine tag environment based on node values.
      #
      # @param node [Chef::Node] the chef node
      #
      # @return [Chef::MachineTagVagrant, Chef::MachineTagRightscale] the machine tag environment
      #
      def get_helper(node)
        Chef::MachineTag.factory(node)
      end
    end
  end
end
