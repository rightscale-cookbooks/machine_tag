# frozen_string_literal: true
#
# Cookbook Name:: fake
# Recipe:: search_tags
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

class Chef::Resource::RubyBlock
  include Chef::MachineTagHelper
end

ruby_block 'searching master tags' do
  block do
    master_tags = tag_search(node, 'master:ip').first
    Chef::Log.info 'Master IP: ' + master_tags['master:ip'].first.value
    Chef::Log.info 'Master Hostname: ' + master_tags['master', 'hostname'].first.value
    Chef::Log.info 'Master Login State: ' + master_tags['master:login'].first.value
  end
end
