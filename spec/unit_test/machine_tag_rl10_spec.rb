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

describe Chef::MachineTagRl10 do
  let(:rs_raw_output) do
    [
      { 'name' => 'database:active=true' },
      { 'name' => 'rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT' },
      { 'name' => 'rs_login:state=restricted' },
      { 'name' => 'rs_monitoring:state=active' },
      { 'name' => 'server:private_ip_0=10.100.0.12' },
      { 'name' => 'server:public_ip_0=157.56.165.202' },
      { 'name' => 'server:uuid=01-83PJQDO8911IT' },
      #    ],
      #    [
      #        {"name"=>"database:active=true"},
      #        {"name"=>"rs_dbrepl:master_active=20130604215532-mylineage"},
      #        {"name"=>"rs_dbrepl:master_instance_uuid=01-25MQ0VQKKDUVQ"},
      #        {"name"=>"rs_login:state=restricted"},
      #        {"name"=>"rs_monitoring:state=active"},
      #        {"name"=>"server:private_ip_0=10.100.0.18"},
      #        {"name"=>"server:public_ip_0=157.56.165.204"},
      #        {"name"=>"server:uuid=01-25MQ0VQKKDUVQ"},
      #        {"name"=>"terminator:discovery_time=Tue Jun 04 22:07:07 +0000 2013"}
      #      ]
    ]
  end

  let(:rs_list_result) do
    [
      { 'name' => 'appserver:active=true' },
      { 'name' => 'appserver:listen_ip=10.254.84.76' },
      { 'name' => 'appserver:listen_port=8000' },
      { 'name' => 'rs_login:state=restricted' },
      { 'name' => 'rs_monitoring:state=active' },
      { 'name' => 'server:private_ip_0=10.254.84.76' },
      { 'name' => 'server:public_ip_0=54.214.187.99' },
      { 'name' => 'server:uuid=01-6P781RDGU1F13' },
    ]
  end

  let!(:provider) do
    provider = Chef::MachineTagRl10.new
    allow(provider).to receive(:initialize_api_client).and_return(client_stub)
    provider
  end

  let(:client_stub) do
    client = double('RightApi::Client', log: nil)
    allow(client).to receive(:get_instance).and_return(instance_stub)
    allow(client).to receive_message_chain('resource.state') { 'operational' }
    allow(client).to receive_message_chain('get_instance.show.cloud.href') { '/api/clouds/6' }
    client
  end

  let!(:instance_stub) { double('instance', links: [], href: 'some_href') }

  let(:tags_stub) { double('tags', tags: rs_raw_output) }

  let(:resources_stub) do
    double('resources',
      links: [{ 'href' => '/api/clouds/6/instances/1234' }]
          )
  end

  let(:resources_stub_fail) do
    double('resources',
      links: [{ 'href' => '/api/clouds/1/instances/1234' }]
          )
  end

  let(:resource_tags_stub) { double('tag_resources', tags: rs_raw_output) }

  before(:each) do
    client = client_stub
    allow(client).to receive_message_chain('get_instance.href') { '/foo' }
    allow(client).to receive_message_chain('get_instance.tags')
    allow(client).to receive_message_chain('tags.multi_add')
    allow(client).to receive_message_chain('tags.multi_delete')
  end

  describe '#create' do
    it 'should create a tag' do
      allow(client_stub.tags).to receive(:multi_add)
        .with(hash_including(resource_hrefs: ['/foo'], tags: ['some:tag=true']))
      provider.create('some:tag=true')
    end
  end

  describe '#delete' do
    it 'should delete a tag' do
      allow(client_stub.tags).to receive(:multi_delete)
        .with(hash_including(resource_hrefs: ['/foo'], tags: ['some:tag=true']))
      provider.delete('some:tag=true')
    end
  end

  describe '#list' do
    it 'should list the tags in the server' do
      allow(client_stub.tags).to receive(:by_resource)
        .with(hash_including(resource_hrefs: ['/foo']))
        .and_return([tags_stub])
      provider.list
    end
  end

  describe '#do_query' do
    it 'should return an array of tag sets containing the query tag' do
      allow(client_stub.tags).to receive(:by_tag)
        .with(hash_including(resource_type: 'instances', tags: ['database:active=true'], match_all: false))
        .and_return([resources_stub])

      allow(client_stub.tags).to receive(:by_resource)
        .with(hash_including(resource_hrefs: ['/api/clouds/6/instances/1234']))
        .and_return([resource_tags_stub])

      tags = provider.send(:do_query, 'database:active=true', match_all: false)
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
        #        MachineTag::Set[
        #          "database:active=true",
        #          "rs_dbrepl:master_active=20130604215532-mylineage",
        #          "rs_dbrepl:master_instance_uuid=01-25MQ0VQKKDUVQ",
        #          "rs_login:state=restricted",
        #          "rs_monitoring:state=active",
        #          "server:private_ip_0=10.100.0.18",
        #          "server:public_ip_0=157.56.165.204",
        #          "server:uuid=01-25MQ0VQKKDUVQ",
        #          "terminator:discovery_time=Tue Jun 04 22:07:07 +0000 2013"
        #        ]
      ]

      expect(tags) == expected_output
    end

    it 'should return an empty array' do
      allow(client_stub.tags).to receive(:by_tag)
        .with(hash_including(resource_type: 'instances', tags: ['something']))
        .and_return([])

      tags = provider.send(:do_query, 'something', match_all: false)
      expect(tags).to be_a(Array)

      expected_output = []

      expect(tags).to eq expected_output
    end
    it 'should raise error because of different cloud' do
      allow(client_stub.tags).to receive(:by_tag)
        .with(hash_including(resource_type: 'instances', tags: ['database:active=true'], match_all: false))
        .and_return([resources_stub_fail])

      expect(client_stub.tags).not_to receive(:by_resource)
        .with(hash_including(resource_hrefs: ['/api/clouds/6/instances/1234']))

      tags = provider.send(:do_query, 'database:active=true', match_all: false)
      expect(tags).to be_a(Array)
      expect(tags).to eq []
    end
  end
end
