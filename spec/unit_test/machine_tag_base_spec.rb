#
# Cookbook Name:: machine_tag
# Spec:: machine_tag_base_spec
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

describe Chef::MachineTagBase do
  MAX_SLEEP_INTERVAL = 60

  let(:base) { Chef::MachineTagBase.new }
  let(:tag_hash_array) do
    [
      {
        'rs_login:state' => 'true',
        'rs_monitoring:state' => 'active'
      },
      {
        'rs_login:state' => 'restricted'
      }
    ]
  end

  let(:tags) do
    '[
      "database:active=true",
      "rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT",
      "rs_login:state=restricted",
      "rs_monitoring:state=active",
      "server:private_ip_0=10.100.0.12",
      "server:public_ip_0=157.56.165.202",
      "server:uuid=01-83PJQDO8911IT",
      "terminator:discovery_time=Tue Jun 04 22:07:12 +0000 2013"
    ]'
  end

  describe "#sleep_interval" do
    it "should return interval less than or equal to #{MAX_SLEEP_INTERVAL}" do
      interval = base.send(:sleep_interval, 1)
      interval.should == 2

      interval = base.send(:sleep_interval, 4)
      interval.should == 16

      interval = base.send(:sleep_interval, 80)
      interval.should == MAX_SLEEP_INTERVAL
    end
  end

  describe "#valid_tag_query" do
    it "should validate the tag passed in the query" do
      valid_tags = [
        'namespace:predicate=value',
        'namespace:predicate=*',
        'n_0abc123:xy_123=-1',
        'naMesPacE:PrEdiCatE=value=value',
        'server:something'
      ]
      valid_tags.each do |tag|
        base.send(:valid_tag_query?, tag).should == 0
      end

      invalid_tags = [
        '_namespace:_predicate=value',
        'namespace:pred*',
        'n*:predicate',
        'namespace:predicate=val*',
        'n- :blah =!'
      ]
      invalid_tags.each do |tag|
        base.send(:valid_tag_query?, tag).should be_nil
      end
    end
  end

  describe "#split_tag" do
    it "should split tag into 2 parts - 'namespace:predicate' and 'value'" do
      value_1, value_2 = base.send(:split_tag, 'some:tag=true')
      value_1.should == 'some:tag'
      value_2.should == 'true'

      value_1, value_2 = base.send(:split_tag, 'some:tag=true=true')
      value_1.should == 'some:tag'
      value_2.should == 'true=true'
    end
  end

  describe "#detect_tag" do
    context "tag is found in the array of tag hashes" do
      it "should return the array of tag hashes containing the tag" do
        output_array = base.send(:detect_tag, tag_hash_array, 'rs_login:state=*')
        output_array.should have(2).items

        output_array = base.send(:detect_tag, tag_hash_array, 'rs_monitoring:state=active')
        output_array.should have(1).items

        output_array = base.send(:detect_tag, tag_hash_array, 'rs_monitoring:state')
        output_array.should have(1).items
      end
    end

    context "tag is not found in the array of tag hashes" do
      it "should return an empty array" do
        output_array = base.send(:detect_tag, tag_hash_array, 'some:state=*')
        output_array.should be_empty
      end
    end
  end

  describe "#create_tag_hash" do
    it "should create a tag hash with 'namespace:predicate' as key and 'value' as value" do
      output_hash = base.send(:create_tag_hash, ['some:tag=1', 'foo:bar=2+5 = 7'])

      output_hash.keys.should == ['some:tag', 'foo:bar']
      output_hash.values.should == ['1', '2+5 = 7']
    end
  end
end
