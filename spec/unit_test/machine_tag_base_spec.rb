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
  let(:tags) do
    <<-EOF
      [
        "database:active=true",
        "rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT",
        "rs_login:state=restricted",
        "rs_monitoring:state=active",
        "server:private_ip_0=10.100.0.12",
        "server:public_ip_0=157.56.165.202",
        "server:uuid=01-83PJQDO8911IT",
        "terminator:discovery_time=Tue Jun 04 22:07:12 +0000 2013"
      ]
    EOF
  end

  describe "#search" do
    let(:tag_hash) { base.send(:create_tag_hash, JSON.parse(tags)) }

    context "when no query options are specified" do
      it "should do a query and return the tags matching the query" do
        base.should_receive(:do_query).with('database:active=true').and_return([tag_hash])

        search_output = base.search('database:active=true')
        search_output.should == [tag_hash]
      end
    end

    context "when query options are specified" do
      context "when 'required_tags' appear in query before query timeout" do
        it "should re-query until 'required_tags' are found in the query" do
          query_tag = 'database:active=true'

          # Mimic a scenario where the required_tags are not found in the query
          # initially, but appears in the query sometime later
          tag_hash_1 = tag_hash.merge('database:master' => 'true')
          tag_hash_2 = tag_hash_1.merge('database:repl' => 'active')
          base.should_receive(:do_query).with(query_tag).at_least(:once).and_return(
            [tag_hash],
            [tag_hash_1],
            [tag_hash_1],
            [tag_hash_2]
          )

          query_options = {
            :required_tags => ['database:master=true', 'database:repl=active']
          }
          search_output = base.search(query_tag, query_options)
          search_output.should == [tag_hash_2]
        end
      end

      context "when 'required_tags' do not appear in query before query timeout" do
        it "should raise a Timeout exception" do
          query_tag = 'database:active=true'

          base.should_receive(:do_query).with(query_tag).at_least(:once).and_return([tag_hash])

          query_options = {
            :required_tags => ['database:master=true'],
            :query_timeout => 1
          }

          expect do
            base.search('database:active=true', query_options)
          end.to raise_error(Timeout::Error)
        end
      end
    end
  end

  describe "#sleep_interval" do
    it "should return interval less than or equal to #{MAX_SLEEP_INTERVAL} seconds" do
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
        base.send(:valid_tag_query?, tag).should be_true
      end

      invalid_tags = [
        '_namespace:_predicate=value',
        'namespace:pred*',
        'n*:predicate',
        'namespace:predicate=val*',
        'n- :blah =!'
      ]
      invalid_tags.each do |tag|
        base.send(:valid_tag_query?, tag).should be_false
      end
    end
  end

  describe "#split_tag" do
    it "should split a tag into 2 parts - 'namespace:predicate' and 'value'" do
      value_1, value_2 = base.send(:split_tag, 'some:tag=true')
      value_1.should == 'some:tag'
      value_2.should == 'true'

      value_1, value_2 = base.send(:split_tag, 'some:tag=true=true')
      value_1.should == 'some:tag'
      value_2.should == 'true=true'
    end
  end

  describe "#detect_tag" do
    let(:tag_hash_array) do
      [
        {'rs_login:state' => 'true', 'rs_monitoring:state' => 'active'},
        {'rs_login:state' => 'restricted'}
      ]
    end

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
