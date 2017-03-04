#
# Cookbook Name:: machine_tag
# Recipe:: default
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

log "Installing 'machine_tag' gem"
include_recipe 'build-essential'

chef_gem 'machine_tag' do
  compile_time true
  action :install
end

chef_gem 'right_api_client' do
  version node['machine_tag']['right_api_client']['gem_version']
  compile_time true
  action :install
end

include_recipe 'chef-sugar'
