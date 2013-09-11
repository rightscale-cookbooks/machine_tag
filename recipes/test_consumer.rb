#
# Cookbook Name:: machine_tag
# Recipe:: test_consumer
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

# see libraries/machine_tag_helper.rb
class Chef::Recipe
  include Chef::MachineTagHelper
end

# search for tags previouly produced on another VM
# see ../Vagrantfile for VM setup and runlist
all_tags = tag_search(node)
Chef::Log.info "All Tags: #{all_tags.inspect}"

# can we extract the IP address of the master?
master_tags = all_tags.select { |tags| tags["test:master"] == "true" }.first
Chef::Log.info master_tags.inspect
raise "Did not find the master tag!" unless master_tags
Chef::Log.info "Master IP is #{master_tags['test:master_ip']}"


