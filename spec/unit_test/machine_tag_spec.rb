# frozen_string_literal: true
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

  describe '::vagrant_params_from_node' do
    it 'should return cache_dir and hostname' do
      node.default['hostname'] = 'some_host'
      node.default['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'

      hostname, cache_dir = Chef::MachineTag.vagrant_params_from_node(node)
      expect(cache_dir).to eq '/vagrant/machine_tag_cache/'
      expect(hostname).to eq 'some_host'
    end

    it 'should raise exception if hostname not found' do
      expect do
        Chef::MachineTag.vagrant_params_from_node(node)
      end.to raise_error(ArgumentError)
    end

    it 'should raise exception if machine_tag hash not found in the node' do
      node.default['hostname'] = 'some_host'
      expect do
        Chef::MachineTag.vagrant_params_from_node(node)
      end.to raise_error(ArgumentError)
    end

    it 'should raise exception if vagrant_tag_cache_dir not found in the node' do
      node.default['hostname'] = 'some_host'
      node.default['machine_tag'] = {}
      expect do
        Chef::MachineTag.vagrant_params_from_node(node)
      end.to raise_error(ArgumentError)
    end
  end

  describe '::factory' do
    let(:shell_out) { Struct.new(:exitstatus) }
    let(:stdout) { Struct.new(:stdout) }

    context 'the rs_tag utility is in the path' do
      it 'should return an object of MachineTagRightscale class' do
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(0))
        expect(Chef::MachineTag.factory(node)).to be_an_instance_of(Chef::MachineTagRightscale)
      end
    end

    context 'cloud provider is vagrant' do
      it 'should return an object of MachineTagVagrant class' do
        node.default['cloud']['provider'] = 'vagrant'
        node.default['hostname'] = 'some_host'
        node.default['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(1))
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rightlink').and_return(shell_out.new(1))
        expect(Chef::MachineTag.factory(node)).to be_an_instance_of(Chef::MachineTagVagrant)
      end
    end

    context 'the rs_tag or rightlink utility is not in the path' do
      it 'should raise exception if cloud provider not found in the node' do
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(1))
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rightlink').and_return(shell_out.new(1))
        expect do
          Chef::MachineTag.factory(node)
        end.to raise_error(RuntimeError)
      end
    end

    context 'rightlink 10 is the provider' do
      it 'should return an object of MachineTagRl10 class' do
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rs_tag').and_return(shell_out.new(1))
        allow(Chef::MachineTag).to receive(:shell_out).with('which', 'rightlink').and_return(shell_out.new(0))
        allow(Chef::MachineTag).to receive(:shell_out).with('rightlink', '-version').and_return(stdout.new('RightLink 10.2.1'))
        expect(Chef::MachineTag.factory(node)).to be_an_instance_of(Chef::MachineTagRl10)
      end
    end
  end
end
