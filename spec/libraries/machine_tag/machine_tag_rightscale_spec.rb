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

require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe Chef::MachineTagRightscale do

  before(:all) do
    RS_RAW_OUTPUT = '{
      "rs-instance-a3cd8e55f106f8c9edfcb84f7d786b19ee7baa46-7712524001": {
        "tags": [
          "database:active=true",
          "rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT",
          "rs_login:state=restricted",
          "rs_monitoring:state=active",
          "server:private_ip_0=10.100.0.12",
          "server:public_ip_0=157.56.165.202",
          "server:uuid=01-83PJQDO8911IT",
          "terminator:discovery_time=Tue Jun 04 22:07:12 +0000 2013"
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
    }'
    RS_LIST_RESULTS = '[
      "appserver:active=true",
      "appserver:listen_ip=10.254.84.76",
      "appserver:listen_port=8000",
      "rs_login:state=restricted",
      "rs_monitoring:state=active",
      "server:private_ip_0=10.254.84.76",
      "server:public_ip_0=54.214.187.99",
      "server:uuid=01-6P781RDGU1F13"
    ]'
  end

  describe "search" do
    it "raises if rs_tag is not available" do
      tag_helper = Chef::MachineTag.factory({"rightscale" => {}})
      lambda{tag_helper.serach("server:private_ip_0")}.should raise_error
    end

    it "returns an array of tag hashes" do
      tag_helper =  Chef::MachineTag.factory({"rightscale" => {}})
      tag_helper.should_receive(:run_rs_tag_util).and_return(RS_RAW_OUTPUT)
      tags = tag_helper.search("server:private_ip_0")
      tags.is_a?(Array).should == true
      tags.first.is_a?(Hash).should == true
    end
  end

end

=begin
$ sudo rs_tag --list
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
=end
