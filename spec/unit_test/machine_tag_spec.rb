#
# Cookbook Name:: machine_tag
# Spec:: machine_tag_spec
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

describe Chef::MachineTag do
  let(:node) { Chef::Node.new }

  describe "::vagrant_params_from_node" do
    it "should return cache_dir and hostname" do
      node.set['hostname'] = 'some_host'
      node.set['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'

      hostname, cache_dir = Chef::MachineTag.vagrant_params_from_node(node)
      cache_dir.should == '/vagrant/machine_tag_cache/'
      hostname.should == 'some_host'
    end

    it "should raise exception if hostname not found" do
      expect do
        Chef::MachineTag.vagrant_params_from_node(node)
      end.to raise_error(ArgumentError)
    end

    it "should raise exception if machine_tag hash not found in the node" do
      node.set['hostname'] = 'some_host'
      expect do
        Chef::MachineTag.vagrant_params_from_node(node)
      end.to raise_error(ArgumentError)
    end

    it "should raise exception if vagrant_tag_cache_dir not found in the node" do
      node.set['hostname'] = 'some_host'
      node.set['machine_tag'] = {}
      expect do
        Chef::MachineTag.vagrant_params_from_node(node)
      end.to raise_error(ArgumentError)
    end
  end

  describe "::factory" do
    let(:shell_out) { Struct.new(:exitstatus) }
    let(:stdout) { Struct.new(:stdout) }

    context "the rs_tag utility is in the path" do
      it "should return an object of MachineTagRightscale class" do
        Chef::MachineTag.should_receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(0))
        Chef::MachineTag.factory(node).should be_an_instance_of(Chef::MachineTagRightscale)
      end
    end

    context "cloud provider is vagrant" do
      it "should return an object of MachineTagVagrant class" do
        node.set['cloud']['provider'] = 'vagrant'
        node.set['hostname'] = 'some_host'
        node.set['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'
        Chef::MachineTag.should_receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(1))
        Chef::MachineTag.should_receive(:shell_out).with('which', 'rightlink').and_return(shell_out.new(1))
        Chef::MachineTag.factory(node).should be_an_instance_of(Chef::MachineTagVagrant)
      end
    end

    context "the rs_tag or rightlink utility is not in the path" do
      it "should raise exception if cloud provider not found in the node" do
        Chef::MachineTag.should_receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(1))
        Chef::MachineTag.should_receive(:shell_out).with('which', 'rightlink').and_return(shell_out.new(1))
        expect do
          Chef::MachineTag.factory(node)
        end.to raise_error(RuntimeError)
      end
    end
    
    context "rightlink 10 is the provider" do
      it "should return an object of MachineTagRl10 class" do

        Chef::MachineTag.should_receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(1))
        Chef::MachineTag.should_receive(:shell_out).with('which', 'rightlink').and_return(shell_out.new(0))
        Chef::MachineTag.should_receive(:shell_out).with('rightlink', '-version').and_return(stdout.new("RightLink 10.2.1"))
        Chef::MachineTag.factory(node).should be_an_instance_of(Chef::MachineTagRl10)
      end
    end
  end
end
