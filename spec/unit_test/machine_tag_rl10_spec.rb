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
    
    [
      {"name"=>"appserver:active=true"},
      {"name"=>"appserver:listen_ip=10.254.84.76"},
      {"name"=> "appserver:listen_port=8000"},
      {"name"=>"rs_login:state=restricted"},
      {"name"=>"rs_monitoring:state=active"},
      {"name"=>"server:private_ip_0=10.254.84.76"},
      {"name"=>"server:public_ip_0=54.214.187.99"},
      {"name"=>"server:uuid=01-6P781RDGU1F13"},
    ]

  end
  
  let!(:provider) do
    provider = Chef::MachineTagRl10.new
    provider.stub(:initialize_api_client).and_return(client_stub)
    provider
  end
  
  let!(:client_stub) do
    client = double('RightApi::Client', :log => nil)
    client.stub(:get_instance).and_return(instance_stub)
    client.stub_chain(:get_instance,:href).and_return("/foo")
    client.stub_chain(:tags, :multi_add)
    client.stub_chain(:tags, :multi_delete)
    client.stub_chain(:tags, :by_resource)
    client.stub_chain(:tags, :by_tag).and_return(rs_raw_output)
    client
  end

  let!(:instance_stub) { double('instance', :links => [], :href => 'some_href') }

  describe "#create" do
    it "should create a tag" do
      client_stub.tags.should_receive(:multi_add).
        with(hash_including(resource_hrefs: ["/foo"],tags:['some:tag=true']))
      provider.create('some:tag=true')
    end
    
  end

  describe "#delete" do
    it "should delete a tag" do
      client_stub.tags.should_receive(:multi_delete).
        with(hash_including(resource_hrefs: ['/foo'], tags:['some:tag=true']))
      provider.delete('some:tag=true')
    end
  end

  describe "#list" do
    it "should list the tags in the server" do
      client_stub.tags.should_receive(:by_resource).
        with(hash_including(resource_hrefs: ['/foo'])).
        and_return(rs_list_result)
      provider.list
    end
  end

  describe "#do_query" do
    it "should return an array of tag sets containing the query tag" do
      client_stub.tags.should_receive(:by_tag).
        with(hash_including(resource_type: 'instances', tags: ['database:active=true'])).
        and_return(rs_raw_output)

      tags = provider.send(:do_query,'database:active=true')
      tags.should be_a(Array)
      tags.first.should be_a(MachineTag::Set)

      expected_output = [
        MachineTag::Set[
          "database:active=true",
          "rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT",
          "rs_login:state=restricted",
          "rs_monitoring:state=active",
          "server:private_ip_0=10.100.0.12",
          "server:public_ip_0=157.56.165.202",
          "server:uuid=01-83PJQDO8911IT"
        ],
        MachineTag::Set[
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
      ]

      tags.should == expected_output
    end
  end
end