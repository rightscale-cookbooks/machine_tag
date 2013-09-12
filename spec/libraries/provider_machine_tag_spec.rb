#
# Cookbook Name:: machine_tag
# Spec:: provider_machine_tag_spec
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

require File.join(File.dirname(__FILE__), "..", "..", "libraries", "provider_machine_tag.rb")
require "chef"

describe Chef::MachineTag do

  before(:each) do
    @tag = "test:foo=bar"
    @vagrant_node = {
      'vagrant' => { 'box_name' => 'mybox' },
      'machine_tag' => { 'vagrant_tag_cache_dir' => '/vagrant/machine_tag_cache/' }
    }
    @node = Chef::Node.new
    @node.default['vagrant']['box_name'] = 'mybox'
    @node.default['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'
    @run_context = Chef::RunContext.new(@node, {}, nil)
  end

  it "creates a tag" do
    @new_resource = Chef::Resource::MachineTag.new(@tag)
    @provider = Chef::Provider::MachineTag.new(@new_resource, @run_context)
    helper_stub = stub("helper", :create => true)
    @provider.should_receive(:get_helper).and_return(helper_stub)
    @provider.load_current_resource
    helper_stub.should_receive(:create).and_return(true)
    @provider.action_create
  end

  it "deletes a tag" do
    @new_resource = Chef::Resource::MachineTag.new(@tag)
    @provider = Chef::Provider::MachineTag.new(@new_resource, @run_context)
    helper_stub = stub("helper", :delete => true)
    @provider.should_receive(:get_helper).and_return(helper_stub)
    @provider.load_current_resource
    helper_stub.should_receive(:delete).and_return(true)
    @provider.action_delete
  end

end
