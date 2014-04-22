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
        'namespace:predicate=value',         # standard format
        'namespace:predicate=val ue',        # space in value
        'namespace:predicate=va:lue',        # value can't have :
        'namespace:predicate=!',             # exclamation in value allowed
        'namespace:predicate=*',             # allow * for value
        'n_0abc123:xy_123=-1',               # mix of alpha, num and underscores allowed as well as -
        'naMesPacE:PrEdiCatE=value',         # mixed case allowed in predicate and value
        'namespace:predicate=value=value',   # value can have an = sign
        'namespace:predicate=vAlUe',         # mixed case in value
        'namespace:predicate==value',        # double ==
        'server:something=1'                 # value is a number
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
        '_namespace:_predicate=value',       # no leading _
        'namespace:pred*',                   # no * in predicate
        'n*:predicate',                      # no * in namespace
        'namespace:predicate=val*',          # no * in value, except if it's by itself as in =*
        'n-mespace:predicate=value',         # no dash in namespace
        'name space:predicate=value',        # no space in namespace
        'namespace:pred icate=value',        # no space in predicate
        'namespace::predicate=value',        # no double ::
        'name!space:predicate=value',        # no ! chars in namespace 
        ':namespace:predicate=value',        # can't start with a :
        'namespace=predicate:value',         # must have : before =
        'name:space:predicate=value',        # can't have more than 1 : before =
        'namespace:predicate'                # missing value
      ]
      invalid_tags.each do |tag|
        expect do
          resource.name(tag)
        end.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
