# frozen_string_literal: true
#
# Cookbook Name:: machine_tag
# Attributes:: default
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

default['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/cache_dir/machine_tag_cache/'
default['build-essential']['compile_time'] = true
default['machine_tag']['right_api_client']['gem_version'] = (Gem::Requirement.new('>= 12.18').satisfied_by?(Gem::Version.new(Chef::VERSION)) ? '1.6.3' : '1.6.2')
