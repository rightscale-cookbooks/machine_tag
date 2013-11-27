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
      run_rs_tag_util("--add", tag)
    end

    # Deletes a tag from the server.
    #
    # @param tag [String] the tag to be deleted
    #
    def delete(tag)
      run_rs_tag_util("--remove", tag)
    end

    # Lists all tags on the server.
    #
    # @return [MachineTag::Set] the tags on the server
    #
    def list
      create_tag_set(JSON.parse(run_rs_tag_util("--list")))
    end


    protected

    # Searches for the given tags on the servers.
    #
    # @param query_tags [Array<String>] the tags to be queried
    #
    # @return [Array<MachineTag::Set>] the tags on the servers that match the query
    #
    def do_query(*query_tags)
      tags_hash = JSON.parse(run_rs_tag_util("--query", query_tags.join(' ')))
      tags_set_array = []
      tags_hash.keys.each do |key|
        tags_set_array << create_tag_set(tags_hash[key]['tags']) if tags_hash[key]['tags']
      end
      tags_set_array
    end

    private

    # Asserts the `rs_tag` utility is in the path.
    #
    def assert_rightscale
      shell_out!("which rs_tag")
    end

    # Runs the `rs_tag` utility.
    #
    # @param args [Array<String>] the arguments for the utility
    #
    # @return [String] the output from the utility
    #
    def run_rs_tag_util(*args)
      assert_rightscale
      cmd = ['rs_tag'] + args
      shell_out!(cmd).stdout
    end
  end
end
