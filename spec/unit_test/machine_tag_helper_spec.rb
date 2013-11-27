#
# Cookbook Name:: machine_tag
# Spec:: machine_tag_spec
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
    node.set['cloud']['provider'] = 'some_cloud'
    node
  end

  let(:env_stub) { double("Chef::MachineTagBase") }

  # Dummy class that will include the Chef::MachineTagHelper module for testing
  class Fake; end

  let(:fake) do
    fake_obj = Fake.new
    fake_obj.extend(Chef::MachineTagHelper)
    fake_obj
  end

  let(:tag_set) { MachineTag::Set['foo:bar=true', 'namespace:predicate=value'] }

  describe ".tag_search" do
    it "should search the given tags and return an array of tag sets" do
      query_tags = ['namespace:predicate=value', 'foo:bar=true']

      Chef::MachineTag.should_receive(:factory).with(node).and_return(env_stub)
      env_stub.should_receive(:search).with(query_tags, {}).and_return([tag_set])
      fake.tag_search(node, query_tags)

      options = {
        :required_tags => ['foo:bar'],
        :query_timeout => 5
      }
      Chef::MachineTag.should_receive(:factory).with(node).and_return(env_stub)
      env_stub.should_receive(:search).with(query_tags, options).and_return([tag_set])
      fake.tag_search(node, query_tags, options)
    end
  end

  describe ".tag_list" do
    it "should list the tags on the server" do
      Chef::MachineTag.should_receive(:factory).with(node).and_return(env_stub)
      env_stub.should_receive(:list).and_return(tag_set)

      fake.tag_list(node)
    end
  end
end
