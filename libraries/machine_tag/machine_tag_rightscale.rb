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

    def create(tag)
      run_rs_tag_util("--add #{tag}")
    end

    def delete(tag)
      run_rs_tag_util("--remove #{tag}")
    end

    def list
      create_tag_hash(run_rs_tag_util)
    end

    def query(query_string)
      stdout = run_rs_tag_util("--query #{query_string}")
      tags_hash = JSON.parse(stdout)
      t_array = []
      tags_hash.keys.each do |key|
        t_array << create_tag_hash(tags_hash[key]["tags"]) if tags_hash[key]["tags"]
      end
      t_array
    end

    private

    # Asserts the `rs_tag` utility is in the path.
    #
    def assert_rightscale
      result = shell_out("which rs_tag")
      result.error!
    end

    # Runs the `rs_tag` utility.
    #
    # @param args [String] the arguments for the utility
    #
    # @return [String] the output from the utility
    #
    def run_rs_tag_util(args = "--list")
      assert_rightscale
      cmd = "rs_tag #{args}"
      results = shell_out(cmd)
      results.error!
      results.stdout
    end

  end
end
