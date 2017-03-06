# frozen_string_literal: true
#
# Cookbook Name:: machine_tag
# Library:: machine_tag_rightscale
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

require_relative 'machine_tag_base'

require 'json'
require 'chef/mixin/shell_out'

class Chef
  class MachineTagRightscale < MachineTagBase
    include Chef::Mixin::ShellOut

    # Creates a tag on the server.
    #
    # @param tag [String] the tag to be created
    #
    def create(tag)
      run_rs_tag_util('--add', tag)
    end

    # Deletes a tag from the server.
    #
    # @param tag [String] the tag to be deleted
    #
    def delete(tag)
      run_rs_tag_util('--remove', tag)
    end

    # Lists all tags on the server.
    #
    # @return [MachineTag::Set] the tags on the server
    #
    def list
      ::MachineTag::Set.new(JSON.parse(run_rs_tag_util('--list')))
    end

    protected

    # Searches for the given tags on the servers.
    #
    # @param query_tags [Array<String>] the tags to be queried
    #
    # @return [Array<MachineTag::Set>] the tags on the servers that match the query
    #
    def do_query(query_tags, _options = {})
      tags_hash = JSON.parse(run_rs_tag_util('--query', query_tags.join(' ')))
      tags_set_array = []
      tags_hash.values.each do |value|
        tags_set_array << ::MachineTag::Set.new(value['tags'])
      end
      tags_set_array
    end

    private

    # Runs the `rs_tag` utility.
    #
    # @param args [Array<String>] the arguments for the utility
    #
    # @return [String] the output from the utility
    #
    def run_rs_tag_util(*args)
      cmd = ['rs_tag'] + args

      # As network issues can cause rs_tag to fail,
      # we will do retries with a timeout.
      Timeout.timeout(120) do
        begin
          shell_out!(cmd).run_command.stdout
        rescue Mixlib::ShellOut::ShellCommandFailed => err_msg
          puts "#{err_msg}\nretrying"
          sleep 2
          retry
        end
      end
    end
  end
end
