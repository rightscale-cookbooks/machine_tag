#
# Cookbook Name:: machine_tag
# Library:: machine_tag_base
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

class Chef
  class MachineTagBase

    # Creates a tag for this server.
    #
    # @param tag [String] the tag to create
    #
    def create(tag)
      not_implemented
    end

    # Deletes a tag for this server.
    #
    # @param tag [String] the tag to delete
    #
    def delete(tag)
      not_implemented
    end

    # Lists all the tags for this server.
    #
    # @return [Hash] the list of tags
    #
    def list
      not_implemented
    end

    def query(query_string = '')
      not_implemented
    end

    # Returns the list of tags for all server that match the query.
    #
    # @param query_string [String] the tags separated by space that should be queried
    # @param options [Hash] the optional parameters for the query
    #
    # @option options [Array<String>] :required_tags the tags that should be found by the query.
    # If the tags are not found at the time of the query, re-query until they are found or the timeout is reached
    # @option options [Integer] :query_timeout the timeout for the query operation
    #
    # @return [Array<String>] the list of tags found
    #
    def search(query_string, options = {})
      if options[:required_tags].nil? || options[:required_tags].empty?
        query(query_string)
      else
        t_array = query(query_string)

        # Set timeout for querying for required_tags
        timeout_sec = options[:query_timeout] ? options[:query_timeout] * 60 : 120
        begin
          Timeout::timeout(timeout_sec) do
            options[:required_tags].each do |tag|
              sleep_sec = 1
              # Check if the tag is found in all the servers in the query result. If not, re-query
              while detect_tag(t_array, tag).length != t_array.length
                # Calculate wait interval for re-querying
                sleep_sec = sleep_interval(sleep_sec)
                Chef::Log.info "Requested tags are not available yet. Waiting for #{sleep_sec} seconds..."
                sleep sleep_sec
                Chef::Log.info "Re-querying for the requested tags..."
                # Re-query the tags
                t_array = query(query_string)
              end
            end
          end
        rescue Timeout::Error => e
          raise e, "Requested tags could not be found within #{timeout_sec} seconds"
        end
        t_array
      end
    end

    private

    # Use the MachineTag.factory method to create this class
    def initalize; end

    # Breaks up tags into <key, value> pairs where the key contains
    # "namespace:predicate" and value contains the tag value.
    #
    # @param tags_array [Array<String>] the array of tags
    #
    # @return [Hash] the tag hash
    #
    def create_tag_hash(tags_array)
      t_hash = {}
      tags_array.each do |tag|
        namespace_predicate, value = tag.split('=')
        t_hash[namespace_predicate] = value
      end
      t_hash
    end

    def detect_tag(tags_hash_array, tag)
      raise "#{tag} is not a valid tag!" unless valid_tag?(tag)

      key, value = tag.split('=')
      tags_hash_array.select do |tags_hash|
        # If tag value is a wildcard, detect tags that match the namespace:predicate (key)
        # else, detect tags that match both namespace:predicate and the value
        if value == '*' || value.nil?
          tags_hash.keys.include?(key)
        else
          tags_hash.keys.include?(key) && tags_hash[key] == value
        end
      end
    end

    def valid_tag?(tag)
      tag =~ /^[a-zA-Z][a-zA-Z0-9_]*:[a-zA-Z][a-zA-Z0-9_]*(=(\*|.+))?/
    end

    def sleep_interval(delay = 1)
      max_sleep_interval = 60
      if delay == 1
        return 2
      elsif delay >= max_sleep_interval
        return max_sleep_interval
      else
        interval = delay * delay
        return interval < max_sleep_interval ? interval : max_sleep_interval
      end
    end

    def not_implemented
      caller[0] =~ /`(.*?)'/
      raise NotImplementedError, "#{$1} is not implemented on #{self.class}"
    end

  end
end
