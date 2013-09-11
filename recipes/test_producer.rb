#
# Cookbook Name:: machine_tag
# Recipe:: test_producer
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

ip_addr = node['cloud']['public_ips'][0] if node['cloud']
ip_addr ||= node['ipaddress']

machine_tag "test:master=true"
machine_tag "test:master_ip=#{ip_addr}"
machine_tag "test:master_hostname=#{node['hostname']}"
