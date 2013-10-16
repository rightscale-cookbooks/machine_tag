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

    # Creates a tag on the VM by adding the tag to its tags cache file
    # if it does not exist.
    #
    # @return [Boolean] true if the tag is successfully added to the tag cache
    #
    def create(tag)
      update_tag_file do |tag_array|
        tag_array << tag unless tag_array.include?(tag)
      end
      true
    end

    # Deletes a tag on the VM by removing the tag from the tags cache file.
    #
    # @return [Boolean] if the tag is successfully deleted from the tag cache
    #
    def delete(tag)
      update_tag_file do |tag_array|
        tag_array.delete(tag)
      end
      true
    end

    # Gets the tags on the VM by reading the contents of the tags cache file.
    #
    # @return [Hash] the tags on the VM
    #
    def list
      create_tag_hash(read_tag_file(@tag_file))
    end

    # Searches for the given tags in the tags cache file on all the VMs.
    #
    # @param query_string [String] the tags to be queried separated by a blank space
    #
    # @return [Array<Hash>] the tags on the VMs that match the query
    #
    def query(query_string)
      query_result = []
      query_tags = query_string.split(' ')

      # Return empty array if no tags are found in the query string
      return query_result if query_tags.empty?

      # Query all VMs for the tags
      all_vm_tag_dirs.each do |tag_dir|
        tags_array = read_tag_file(::File.join(tag_dir, TAGS_JSON_FILE))
        if tags_array
          tags_hash_array = []
          tags_hash_array << create_tag_hash(tags_array)

          # If at least one of the tags in the query is found in the VM
          # select the VM
          query_tags.each do |tag|
            unless detect_tag(tags_hash_array, tag).empty?
              query_result += tags_hash_array
              break
            end
          end
        end
      end
      query_result
    end

    private

    def initialize(hostname, cache_dir)
      @hostname = hostname
      @cache_dir = ::File.join(cache_dir, @hostname)
      @tag_file = ::File.join(@cache_dir, TAGS_JSON_FILE)
    end

    # These private methods are thanks to Ryan Geyer's work in his
    # rs_vagrant_shim project:
    #  https://github.com/rgeyer-rs-cookbooks/rs_vagrant_shim

    # Updates the contents of the tag file.
    #
    def update_tag_file
      make_cache_dir
      begin
        tag_array = read_tag_file(@tag_file)
        yield tag_array
        write_tag_file(tag_array)
      end
    end

    # Creates tag cache directory in the VM.
    #
    def make_cache_dir
      ::FileUtils.mkdir_p @cache_dir unless ::File.directory? @cache_dir
    end

    # Reads the contents of json file into an array.
    #
    # @return [Array] the file contents if file exists, an empty array otherwise
    #
    def read_tag_file(filename)
      if ::File.exist? filename
        JSON.parse(::File.read(filename))
      else
        []
      end
    end

    # Writes the contents of tag array to a json file.
    #
    # @return [Boolean] true if file successfully written
    #
    def write_tag_file(tag_array)
      ::File.open(@tag_file, 'w') do |file|
        file.write(JSON.pretty_generate(tag_array))
      end
      true
    end

    # Gets all the VM tag cache directories.
    #
    # @return [Array] the VM tag cache directories
    #
    def all_vm_tag_dirs
      path_for_glob = ::File.expand_path(::File.join(@cache_dir, '..') + '/*')
      Dir.glob(path_for_glob)
    end

  end
end
