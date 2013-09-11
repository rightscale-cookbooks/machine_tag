#
# Cookbook Name:: machine_tag
# Recipe:: test_tags
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

# see libaries/machine_tag_helper.rb
class Chef::Resource
  include Chef::MachineTagHelper
end

# add a tag to myself
machine_tag "test:slave=true"

# now see if I can list my tags
ruby_block "look for my tags" do
  block do
    my_tags = tag_list(node)
    Chef::Log.info "My Tags: #{my_tags.inspect}"
    raise "Did not find the my tag!" unless my_tags.has_key?("test:slave")
  end
end
