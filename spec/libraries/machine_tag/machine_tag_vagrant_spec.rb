#
# Cookbook Name:: machine_tag
# Spec:: machine_tag_vagrant_spec
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

describe Chef::MachineTagVagrant do

  before(:all) do
    @vagrant_node = {
      'vagrant' => { 'box_name' => 'mybox' },
      'machine_tag' => { 'vagrant_tag_cache_dir' => '/vagrant/machine_tag_cache/' }
    }

    REMOTE_TAGS = '[
      "database:active=true",
      "rs_dbrepl:slave_instance_uuid=01-83PJQDO8911IT",
      "rs_login:state=restricted",
      "rs_monitoring:state=active",
      "server:private_ip_0=10.100.0.12",
      "server:public_ip_0=157.56.165.202",
      "server:uuid=01-83PJQDO8911IT",
      "terminator:discovery_time=Tue Jun 04 22:07:12 +0000 2013"
    ]'

    LOCAL_TAGS = '[
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

  describe "create" do
    it "creates a tag" do
      tag_helper = Chef::MachineTag.factory(@vagrant_node)
      tag_helper.should_receive(:make_cache_dir)
      tag_helper.should_receive(:read_tag_file).and_return(JSON.parse(LOCAL_TAGS))
      tag_helper.should_receive(:write_tag_file)
      tag_helper.create("test:tags=foo")
    end
  end

  describe "delete" do
    it "deletes a tag" do
      tag_helper = Chef::MachineTag.factory(@vagrant_node)
      tag_helper.should_receive(:make_cache_dir)
      tag_helper.should_receive(:read_tag_file).and_return(JSON.parse(LOCAL_TAGS))
      tag_helper.should_receive(:write_tag_file)
      tag_helper.delete("appserver:active=true")
    end
  end

  describe "list" do
    it "lists tags" do
      tag_helper = Chef::MachineTag.factory(@vagrant_node)
      tag_helper.should_receive(:make_cache_dir)
      tag_helper.should_receive(:read_tag_file).and_return(JSON.parse(LOCAL_TAGS))
      tag_helper.should_receive(:write_tag_file)
      list = tag_helper.list
      list["appserver:active"].should == "true"
    end
  end

  describe "search" do
    it "returns array of tag hashes" do
      tag_helper = Chef::MachineTag.factory(@vagrant_node)
      tag_helper.should_receive(:all_vm_tag_dirs).and_return(["/tmp/master", "/tmp/slave"])
      tag_helper.should_receive(:read_tag_file).and_return(JSON.parse(LOCAL_TAGS))
      tag_helper.should_receive(:read_tag_file).and_return(JSON.parse(REMOTE_TAGS))
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

