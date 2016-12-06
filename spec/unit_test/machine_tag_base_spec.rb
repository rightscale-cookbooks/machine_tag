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

  before do
    allow(Kernel).to receive(:sleep) {|seconds| seconds}
  end

  describe '#search' do
    let(:tag_set) do
      ::MachineTag::Set[
        'database:active=true',
        'rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT',
        'rs_login:state=restricted',
        'rs_monitoring:state=active',
        'server:private_ip_0=10.100.0.12',
        'server:public_ip_0=157.56.165.202',
        'server:uuid=01-83PJQDO8911IT',
        'terminator:discovery_time=Tue Jun 04 22:07:12 +0000 2013'
      ]
    end

    context 'when no query options are specified' do
      it 'should do a query and return the tags matching the query' do
        allow(base).to receive(:do_query).with(['database:active=true'],{}).and_return([tag_set])

        search_output = base.search('database:active=true')
        expect(search_output).to eq [tag_set]

        allow(base).to receive(:do_query).with([
          'database:active=true', 'rs_monitoring:state=active'
        ],{}).and_return([tag_set])

        search_output = base.search(['database:active=true', 'rs_monitoring:state=active'])
        expect(search_output).to eq [tag_set]
      end
    end

    context 'when query options are specified' do
      context "when 'required_tags' appear in query before query timeout" do
        it "should re-query until 'required_tags' are found in the query" do
          # Mimic a scenario where the required_tags are not found in the query
          # initially, but appears in the query sometime later
          tag_set_partial = tag_set.union(['database:master=true'])
          tag_set_full = tag_set_partial.union(['database:repl=active'])
          allow(base).to receive(:do_query).with(['database:active=true'],{:required_tags=>["database:master=true", "database:repl=active"]}).exactly(4).and_return(
            [tag_set],
            [tag_set_partial],
            [tag_set_partial],
            [tag_set_full],
          )

          query_options = {
            required_tags: ['database:master=true', 'database:repl=active']
          }
          search_output = base.search('database:active=true', query_options)
          expect(search_output).to eq [tag_set_full]
        end
      end

      context "when 'required_tags' do not appear in query before query timeout" do
        it 'should raise a Timeout exception' do
          query_tag = 'database:active=true'

          query_options = {
            required_tags: ['database:master=true'],
            query_timeout: 1,
          }

          allow(base).to receive(:do_query).with([query_tag],query_options).at_least(:once).and_return([tag_set])

          expect do
            base.search('database:active=true', query_options)
          end.to raise_error(Timeout::Error)
        end
      end
    end
  end

  describe '#sleep_interval' do
    it "should return interval less than or equal to #{MAX_SLEEP_INTERVAL} seconds" do
      interval = base.send(:sleep_interval, 1)
      expect(interval).to eq(2)

      interval = base.send(:sleep_interval, 4)
      expect(interval).to eq(16)

      interval = base.send(:sleep_interval, 80)
      expect(interval).to eq MAX_SLEEP_INTERVAL
    end
  end

  describe '#valid_tag_query?' do
    it 'should validate the tag passed in the query' do
      valid_tags = [
        'namespace:predicate=value',
        'namespace:predicate=*',
        'n_0abc123:xy_123=-1',
        'naMesPacE:PrEdiCatE=value=value',
        'server:something',
      ]
      valid_tags.each do |tag|
        expect(base.send(:valid_tag_query?, MachineTag::Tag.new(tag))).to be_truthy
      end

      invalid_tags = [
        '_namespace:_predicate=value',
        'namespace:pred*',
        'n*:predicate',
        'namespace:predicate=val*',
        'n- :blah =!',
      ]
      invalid_tags.each do |tag|
        expect(base.send(:valid_tag_query?, MachineTag::Tag.new(tag))).to be_falsey
      end
    end
  end

  describe '#detect_tag' do
    let(:tag_set_array) do
      [
        MachineTag::Set['rs_login:state=true', 'rs_monitoring:state=active'],
        MachineTag::Set['rs_login:state=restricted'],
      ]
    end

    context 'tag is found in the array of tag sets' do
      it 'should return the array of tag sets containing the tag' do
        output_array = base.send(:detect_tag, tag_set_array, 'rs_login:state=*')
        expect(output_array.size).to eq(2)

        output_array = base.send(:detect_tag, tag_set_array, 'rs_monitoring:state=active')
        expect(output_array.size).to eq(1)

        output_array = base.send(:detect_tag, tag_set_array, 'rs_monitoring:state')
        expect(output_array.size).to eq(1)
      end
    end

    context 'tag is not found in the array of tag sets' do
      it 'should return an empty array' do
        output_array = base.send(:detect_tag, tag_set_array, 'some:state=*')
        expect(output_array).to be_empty
      end
    end
  end
end
