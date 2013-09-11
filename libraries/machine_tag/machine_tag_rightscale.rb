require "json"
require 'chef/mixin/shell_out'

class Chef
  class MachineTagRightscale < MachineTagBase

    include Chef::Mixin::ShellOut

    def create(tag)
      run_rs_tag_util("--add #{tag}")
    end

    def search(query=nil, args={})
      stdout = run_rs_tag_util("--query #{query}")
      t_hash = JSON.parse(stdout)
      t_array = []
      t_hash.keys.each do |key|
        t_array << create_tag_hash(t_hash[key]["tags"]) if t_hash[key]["tags"]
      end
      t_array
    end

    def list
      run_rs_tag_util
    end

    private

    # Break up tags into key, value pairs
    # where the key contains "namespace:predicate"
    def create_tag_hash(tags_array)
      t_hash = {}
      tags_array.each do |tag|
        namespace_predicate, value = tag.split('=')
        t_hash[namespace_predicate] = value
      end
      t_hash
    end

    # make sure the `rs_tag` utility is in our path
    def assert_rightscale
      result = shell_out("which rs_tag")
      result.error!
    end

    # run the `rs_tag` utility
    def run_rs_tag_util(args="--list")
      assert_rightscale
      cmd = "rs_tag #{args}"
      results = shell_out(cmd)
      results.error!
      results.stdout
    end

  end
end