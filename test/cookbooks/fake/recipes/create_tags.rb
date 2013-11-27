#
# Cookbook Name:: fake
# Recipe:: create_tags
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

include_recipe 'machine_tag::default'

ip_addr = node['cloud']['public_ips'][0] if (node['cloud'] && node['cloud']['public_ips'])
ip_addr ||= node['ipaddress']

machine_tag "master:ip=#{ip_addr}" do
  action :create
end

machine_tag "master:hostname=#{node['hostname']}" do
  action :create
end

machine_tag "master:login=restricted"
