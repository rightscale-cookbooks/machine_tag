#
# Cookbook Name:: machine_tag
# Library:: machine_tag_vagrant
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

class Chef
  class MachineTagVagrant < MachineTagBase
    TAGS_JSON_FILE = 'tags.json'

    def create(tag)
      read_write_my_persist_file do |tag_array|
        tag_array << tag unless tag_array.include? tag
      end
      true
    end

    def delete(tag)
      read_write_my_persist_file do |tag_array|
        tag_array.delete(tag)
      end
      true
    end

    def list
      list = nil
      read_write_my_persist_file do |tag_array|
        list = tag_array
      end
      create_tag_hash(list)
    end

    def query(query_string, options = {})
      query_result = []

      # Query all VMs for the tags
      all_vm_tag_dirs.each do |tag_dir|
        tag_file = ::File.join(tag_dir, TAGS_JSON_FILE)
        tag_array = read_tag_file(tag_file)
        if tag_array
          t_array = []
          t_array << create_tag_hash(tag_array)

          # Select the VM if any of the tags in the query are found in the hash
          query_string.split(' ').each do |queried_tag|
            query_result += t_array if detect_tag(t_array, queried_tag)
          end
        end
      end
      query_result
    end

    private

    def initialize(box_name, cache_dir)
      @box_name = box_name
      @cache_dir = ::File.join(cache_dir, "#{@box_name}")
      @tag_file = ::File.join(@cache_dir, TAGS_JSON_FILE)
    end

    # These private methods are thanks to Ryan Geyer's work in his
    # rs_vagrant_shim project:
    #  https://github.com/rgeyer-rs-cookbooks/rs_vagrant_shim

    # Accesses the persist.json file in the shim directory of "this" VM.
    #
    # Expects to be passed a block which will have a hash yielded to it.  That hash
    # will represent the current contents of the persist.json file.  When the block
    # returns, any changes to the hash will be written back to the persist.json file
    def read_write_my_persist_file
      make_cache_dir
      begin
        tag_hash = read_tag_file(@tag_file)
        yield tag_hash
        write_tag_file(tag_hash)
      end
    end

    def make_cache_dir
      ::FileUtils.mkdir_p @cache_dir unless ::File.directory? @cache_dir
    end

    # Reads the contents of json file into an array
    #
    # @return An array representing the contents of the file, or an empty Array if the file does not exist
    def read_tag_file(filename)
      if ::File.exist? filename
        JSON.parse(::File.read(filename))
      else
        []
      end
    end

    # Writes the contents of tag array to a json file
    #
    # @return true
    def write_tag_file(tag_hash)
      ::File.open(@tag_file, 'w') do |file|
        file.write(JSON.pretty_generate(tag_hash))
      end
      true
    end

    def all_vm_tag_dirs
      path_for_glob = ::File.expand_path(::File.join(@cache_dir, '..') + '/*')
      Dir.glob(path_for_glob)
    end

  end
end
