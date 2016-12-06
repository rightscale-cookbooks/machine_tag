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

require "spec_helper"

describe Chef::Provider::MachineTag do
  let(:provider) do
    provider = Chef::Provider::MachineTag.new(new_resource, run_context)
    allow(provider).to receive(:get_helper).and_return(helper_stub)
    provider
  end

  let(:new_resource) { Chef::Resource::MachineTag.new(tag) }
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:node) do
    node = Chef::Node.new
    node.default['hostname'] = 'some_host'
    node.default['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'
    node
  end
  let(:tag) { 'namespace:predicate=value' }

  let(:helper_stub) { double('machine_tag_helper') }

  describe 'actions' do
    before(:each) do
      provider.load_current_resource
    end

    it "should create a tag" do
      expect(helper_stub).to receive(:create).with(tag)
      provider.run_action(:create)
    end

    it "should delete a tag" do
      expect(helper_stub).to receive(:delete).with(tag)
      provider.run_action(:delete)
    end
  end
end
