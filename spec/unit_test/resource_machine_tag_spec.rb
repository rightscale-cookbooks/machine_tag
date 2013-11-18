#
# Cookbook Name:: machine_tag
# Spec:: resource_machine_tag_spec
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

describe Chef::Resource::MachineTag do
  let(:resource) { Chef::Resource::MachineTag.new('machine_tag', run_context) }
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:node) { Chef::Node.new }

  context "tag syntax is valid" do
    it "has a name attribute to set the name of the tag" do
      valid_tags = [
        'namespace:predicate=value',
        'namespace:predicate=*',
        'n_0abc123:xy_123=-1',
        'naMesPacE:PrEdiCatE=value=value',
        'server:something=1'
      ]
      valid_tags.each do |tag|
        resource.name(tag)
        resource.name.should == tag
      end
    end
  end

  context "tag syntax is invalid" do
    it "should raise error" do
      invalid_tags = [
        '_namespace:_predicate=value',
        'namespace:pred*',
        'n*:predicate',
        'namespace:predicate=val*',
        'n- :blah =!'
      ]
      invalid_tags.each do |tag|
        expect do
          resource.name(tag)
        end.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
