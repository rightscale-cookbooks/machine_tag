# frozen_string_literal: true
#
# Cookbook Name:: machine_tag
# Library:: resource_machine_tag
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

require 'chef/resource'

class Chef
  class Resource
    class MachineTag < Chef::Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :machine_tag
        @allowed_actions.push(:create, :delete)
        @provider = Chef::Provider::MachineTag
        @action = :create
      end

      # Name of the machine tag
      #
      # @param arg [String] the machine tag name
      #
      # @return [String] the machine tag name
      #
      def name(arg = nil)
        require 'machine_tag'
        set_or_return(
          :name,
          arg,
          kind_of: String,
          regex: /^#{::MachineTag::NAMESPACE_AND_PREDICATE}=(?<value>\*|[^*]+)$/
        )
      end
    end
  end
end
