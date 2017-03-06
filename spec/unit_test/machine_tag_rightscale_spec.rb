# frozen_string_literal: true
#
# Cookbook Name:: machine_tag
# Spec:: machine_tag_rightscale_spec
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

describe Chef::MachineTagRightscale do
  let(:rs_raw_output) do
    <<-EOF
      {
        "rs-instance-a3cd8e55f106f8c9edfcb84f7d786b19ee7baa46-7712524001": {
          "tags": [
            "database:active=true",
            "rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT",
            "rs_login:state=restricted",
            "rs_monitoring:state=active",
            "server:private_ip_0=10.100.0.12",
            "server:public_ip_0=157.56.165.202",
            "server:uuid=01-83PJQDO8911IT"
          ]
        },
        "rs-instance-29ad5f04e6c298d9b7837b200c80429da8a3f0b5-7712573001": {
          "tags": [
            "database:active=true",
            "rs_dbrepl:master_active=20130604215532-mylineage",
            "rs_dbrepl:master_instance_uuid=01-25MQ0VQKKDUVQ",
            "rs_login:state=restricted",
            "rs_monitoring:state=active",
            "server:private_ip_0=10.100.0.18",
            "server:public_ip_0=157.56.165.204",
            "server:uuid=01-25MQ0VQKKDUVQ",
            "terminator:discovery_time=Tue Jun 04 22:07:07 +0000 2013"
          ]
        }
      }
    EOF
  end

  let(:rs_list_result) do
    <<-EOF
      [
        "appserver:active=true",
        "appserver:listen_ip=10.254.84.76",
        "appserver:listen_port=8000",
        "rs_login:state=restricted",
        "rs_monitoring:state=active",
        "server:private_ip_0=10.254.84.76",
        "server:public_ip_0=54.214.187.99",
        "server:uuid=01-6P781RDGU1F13"
      ]
    EOF
  end

  let(:tag_helper) { Chef::MachineTagRightscale.new }

  describe '#create' do
    it 'should create a tag' do
      allow(tag_helper).to receive(:run_rs_tag_util).with('--add', 'some:tag=true')
      tag_helper.create('some:tag=true')
    end
  end

  describe '#delete' do
    it 'should delete a tag' do
      allow(tag_helper).to receive(:run_rs_tag_util).with('--remove', 'some:tag=true')
      tag_helper.delete('some:tag=true')
    end
  end

  describe '#list' do
    it 'should list the tags in the server' do
      allow(tag_helper).to receive(:run_rs_tag_util).with('--list').and_return(rs_list_result)
      tag_helper.list
    end
  end

  describe '#do_query' do
    it 'should return an array of tag sets containing the query tag' do
      allow(tag_helper).to receive(:run_rs_tag_util).with('--query', 'database:active=true').and_return(rs_raw_output)

      tags = tag_helper.send(:do_query, ['database:active=true'])
      expect(tags).to be_a(Array)
      expect(tags.first).to be_a(MachineTag::Set)

      expected_output = [
        MachineTag::Set[
          'database:active=true',
          'rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT',
          'rs_login:state=restricted',
          'rs_monitoring:state=active',
          'server:private_ip_0=10.100.0.12',
          'server:public_ip_0=157.56.165.202',
          'server:uuid=01-83PJQDO8911IT'
        ],
        MachineTag::Set[
          'database:active=true',
          'rs_dbrepl:master_active=20130604215532-mylineage',
          'rs_dbrepl:master_instance_uuid=01-25MQ0VQKKDUVQ',
          'rs_login:state=restricted',
          'rs_monitoring:state=active',
          'server:private_ip_0=10.100.0.18',
          'server:public_ip_0=157.56.165.204',
          'server:uuid=01-25MQ0VQKKDUVQ',
          'terminator:discovery_time=Tue Jun 04 22:07:07 +0000 2013'
        ],
      ]

      expect(tags).to eq expected_output
    end
  end
end
