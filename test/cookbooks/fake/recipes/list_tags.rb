#
# Cookbook Name:: fake
# Recipe:: list_tags
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

ruby_block 'listing master tags' do
  block do
    tags_list = tag_list(node)
    Chef::Log.info tags_list.inspect
  end
end
