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

require 'spec_helper'

describe Chef::MachineTagVagrant do
  let(:node) do
    node = Chef::Node.new
    node.set['hostname'] = 'some_host'
    node.set['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'
    node.set['cloud']['provider'] = 'vagrant'
    node
  end

  let(:remote_tags) do
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

  let(:local_tags) do
   '[
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

  let(:tag_helper) { Chef::MachineTag.factory(node) }

  describe "public methods" do
    before(:each) do
      tag_helper.stub(:make_cache_dir)
      tag_helper.stub(:read_tag_file).and_return(JSON.parse(local_tags))
      tag_helper.stub(:write_tag_file)
    end

    describe "#create" do
      it "should create a tag" do
        tag_helper.create('test:tags=foo')

        tag_helper.list['test:tags'].should == 'foo'
      end
    end

    describe "#delete" do
      it "should delete a tag" do
        tag_helper.delete('appserver:active=true')

        tag_helper.list['appserver:active'].should be_nil
      end
    end

    describe "#list" do
      it "should list tags" do
        tag_helper.list['rs_login:state'].should == 'restricted'
      end
    end

    describe "#query" do
      before(:each) do
        tag_helper.stub(:all_vm_tag_dirs).and_return(["/tmp/master", "/tmp/slave"])
        tag_helper.stub(:read_tag_file).and_return(JSON.parse(remote_tags))
      end

      context "query tag exists in the system" do
        it "should return array of tag hashes containing the query tag" do
          tags = tag_helper.query('server:private_ip_0')
          tags.should be_a(Array)
          tags.first.should be_a(Hash)
        end
      end

      context "query tag does not exist in the system" do
        it "should return empty array" do
          tags = tag_helper.query('server:something=*')
          tags.should be_a(Array)
          tags.should be_empty
        end
      end
    end
  end

  describe "private methods" do
    describe "#update_tag_file" do
      it "should update tag json file" do
        tag_helper.should_receive(:make_cache_dir)
        tag_helper.should_receive(:read_tag_file).and_return(JSON.parse(remote_tags))
        tag_helper.should_receive(:write_tag_file)

        tag_helper.send(:update_tag_file) {}
      end
    end

    describe "#make_cache_dir" do
      context "cache directory does not exist" do
        it "should create tag cache dir" do
          File.should_receive(:directory?).and_return(false)
          FileUtils.should_receive(:mkdir_p)

          tag_helper.send(:make_cache_dir)
        end
      end

      context "cache directory exists" do
        it "should not create tag cache dir" do
          File.should_receive(:directory?).and_return(true)
          FileUtils.should_not_receive(:mkdir_p)

          tag_helper.send(:make_cache_dir)
        end
      end
    end

    describe "#read_tag_file" do
      context "tag file exists in the cache directory" do
        it "should return the tags array from the file" do
          File.should_receive(:exist?).and_return(true)
          File.should_receive(:read).and_return(local_tags)

          tags = tag_helper.send(:read_tag_file, 'something')
          tags.should_not be_empty
        end
      end

      context "tag file does not exist in the cache directory" do
        it "should return an empty array" do
          File.should_receive(:exist?).and_return(false)

          tags = tag_helper.send(:read_tag_file, 'something')
          tags.should be_empty
        end
      end
    end
  end
end
