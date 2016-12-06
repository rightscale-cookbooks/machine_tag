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
  let(:remote_tags) do
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

  let(:local_tags) do
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

  let(:tag_helper) { Chef::MachineTagVagrant.new('somehost', '/vagrant/machine_tag_cache/') }

  describe "public methods" do
    let(:tags_array) { JSON.parse(local_tags) }

    before(:each) do
      allow(tag_helper).to receive(:make_cache_dir)
      allow(tag_helper).to receive(:read_tag_file).and_return(tags_array)
    end

    describe "#create" do
      context "tag to be created does not already exist" do
        it "should create a tag" do
          tag = 'test:tags=foo'

          allow(tag_helper).to receive(:write_tag_file).with(tags_array.push(tag))
          tag_helper.create(tag)

          expect(tag_helper.list['test:tags'].first).to eq tag
        end
      end

      context "tag to be created already exists" do
        it "should not create a duplicate tag" do
          allow(tag_helper).to receive(:write_tag_file).with(tags_array)
          tag_helper.create('appserver:active=true')

          expect(tag_helper.list['appserver:active'].length).to eq 1
        end
      end
    end

    describe "#delete" do
      context "tag to be deleted exists" do
        it "should delete a tag" do
          tag = 'appserver:active=true'
          tags_array.delete(tag)
          allow(tag_helper).to receive(:write_tag_file).with(tags_array)
          tag_helper.delete(tag)

          expect(tag_helper.list['appserver:active']).to be_empty
        end
      end
    end

    describe "#list" do
      it "should list tags" do
        expect(tag_helper.list['rs_login:state'].first).to eq 'rs_login:state=restricted'
      end
    end

    describe "#do_query" do
      before(:each) do
        allow(tag_helper).to receive(:all_vm_tag_dirs).and_return(["/tmp/master", "/tmp/slave"])
        allow(tag_helper).to receive(:read_tag_file).and_return(JSON.parse(remote_tags))
      end

      context "query tag exists in the system" do
        it "should return array of tag sets containing the query tag" do
          tags = tag_helper.send(:do_query, ['server:private_ip_0'])
          expect(tags).to be_a(Array)
          expect(tags.first).to be_a(MachineTag::Set)

          expected_tag_set = ::MachineTag::Set.new(JSON.parse(remote_tags))
          expect(tags).to eq Array.new(2) { expected_tag_set }
        end
      end

      context "query tag does not exist in the system" do
        it "should return empty array" do
          tags = tag_helper.send(:do_query, ['server:something=*'])
          expect(tags).to be_a(Array)
          expect(tags).to be_empty
        end
      end
    end
  end

  describe "private methods" do
    describe "#update_tag_file" do
      it "should update tag json file" do
        tags_array = JSON.parse(remote_tags)
        tag = 'create:some=tag'

        allow(tag_helper).to receive(:make_cache_dir)
        allow(tag_helper).to receive(:read_tag_file).and_return(tags_array)
        allow(tag_helper).to receive(:write_tag_file).with(tags_array.push(tag))

        tag_helper.send(:update_tag_file) do |tag_array|
          tag_array << tag
        end
      end
    end

    describe "#make_cache_dir" do
      context "cache directory does not exist" do
        it "should create tag cache dir" do
          expect(File).to receive(:directory?).and_return(false)
          expect(FileUtils).to receive(:mkdir_p).with('/vagrant/machine_tag_cache/somehost')

          tag_helper.send(:make_cache_dir)
        end
      end

      context "cache directory exists" do
        it "should not create tag cache dir" do
          expect(File).to receive(:directory?).and_return(true)
          expect(FileUtils).to_not receive(:mkdir_p)

          tag_helper.send(:make_cache_dir)
        end
      end
    end

    describe "#read_tag_file" do
      context "tag file exists in the cache directory" do
        it "should return the tags array from the file" do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(local_tags)

          tags = tag_helper.send(:read_tag_file, 'something')
          expect(tags).to_not  be_empty
        end
      end

      context "tag file does not exist in the cache directory" do
        it "should return an empty array" do
          expect(File).to receive(:exist?).and_return(false)

          tags = tag_helper.send(:read_tag_file, 'something')
          expect(tags).to be_empty
        end
      end
    end
  end
end
