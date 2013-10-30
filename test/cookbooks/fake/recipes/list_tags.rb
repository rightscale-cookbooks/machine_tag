#
# Cookbook Name:: machine_tag
# Recipe:: delete_tag
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

machine_tag "test:tag1=true" do
  action :create
end

machine_tag "test:tag2=true" do
  action :create
end

machine_tag "test:tag3=true" do
  action :create
end

ruby_block "listing tags" do
  block do
    tags_list = tag_list(node)
    puts tags_list.inspect
  end
end
