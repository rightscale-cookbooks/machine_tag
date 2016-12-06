#
# Cookbook Name:: machine_tag
# Spec:: machine_tag_helper_spec
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

require 'spec_helper'

describe Chef::MachineTagHelper do
  let(:node) do
    node = Chef::Node.new
    node.default['cloud']['provider'] = 'some_cloud'
    node
  end

  let(:env_stub) { double('Chef::MachineTagBase') }

  let(:tag_set) { MachineTag::Set['foo:bar=true', 'namespace:predicate=value'] }

  describe '.tag_search' do
    it 'should search for the given tag(s) and return an array of tag sets' do
      query_tag = 'namespace:predicate=value'
      query_tags = [query_tag, 'foo:bar=true']

      allow(Chef::MachineTag).to receive(:factory).at_least(2).with(node).and_return(env_stub)

      allow(env_stub).to receive(:search).with(query_tag, {}).and_return([tag_set])
      tags = Chef::MachineTagHelper.tag_search(node, query_tag)
      expect(tags).to be_instance_of(Array)
      expect(tags.first).to be_instance_of(MachineTag::Set)
      expect(tags.first).to eq(tag_set)

      allow(env_stub).to receive(:search).with(query_tags, {}).and_return([tag_set])
      tags = Chef::MachineTagHelper.tag_search(node, query_tags)
      expect(tags).to be_instance_of(Array)
      expect(tags.first).to be_instance_of(MachineTag::Set)
      expect(tags.first).to eq(tag_set)

      options = {
        required_tags: ['foo:bar'],
        query_timeout: 5,
      }

      allow(env_stub).to receive(:search).with(query_tag, options).and_return([tag_set])
      tags = Chef::MachineTagHelper.tag_search(node, query_tag, options)
      expect(tags).to  be_instance_of(Array)
      expect(tags.first).to be_instance_of(MachineTag::Set)
      expect(tags.first).to eq(tag_set)

      allow(env_stub).to receive(:search).with(query_tags, options).and_return([tag_set])
      tags = Chef::MachineTagHelper.tag_search(node, query_tags, options)
      expect(tags).to be_instance_of(Array)
      expect(tags.first).to be_instance_of(MachineTag::Set)
      expect(tags.first).to eq tag_set
    end
  end

  describe '.tag_list' do
    it 'should list the tags on the server' do
      allow(Chef::MachineTag).to receive(:factory).with(node).and_return(env_stub)
      allow(env_stub).to receive(:list).and_return(tag_set)

      tags = Chef::MachineTagHelper.tag_list(node)
      expect(tags).to be_instance_of(MachineTag::Set)
      expect(tags).to eq tag_set
    end
  end
end
