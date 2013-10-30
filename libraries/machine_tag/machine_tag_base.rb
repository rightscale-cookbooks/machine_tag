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

    # Default query timeout (in seconds).
    #
    DEFAULT_QUERY_TIMEOUT = 120

    # Maximum value for sleep interval (in seconds) when re-querying tags.
    #
    MAX_SLEEP_INTERVAL = 60

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

    # Queries the tags passed through the query string.
    #
    # @param query_string [String] the tags to be queried separated by blank space
    #
    # @return [Array<Hash>] the list of all tags on the servers that match the query
    #
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
    # @return [Array<Hash>] the array of all tags (in hash format) on the servers
    # that match the query
    #
    # @raise [Timeout::Error] if the required tags could not be found within the time
    #
    def search(query_string, options = {})
      if options[:required_tags].nil? || options[:required_tags].empty?
        return query(query_string)
      else
        tags_hash_array = query(query_string)

        # Set timeout for querying for required_tags. By default the timeout is set
        # for 120 seconds if no timeouts specified.
        timeout_sec = if options[:query_timeout]
          options[:query_timeout] * 60
        else
          DEFAULT_QUERY_TIMEOUT
        end

        begin
          Timeout::timeout(timeout_sec) do
            options[:required_tags].each do |tag|
              sleep_sec = 1
              # Check if the tag is found in all the servers in the query result. If not, re-query
              while detect_tag(tags_hash_array, tag).length != tags_hash_array.length
                # Calculate wait interval for re-querying
                sleep_sec = sleep_interval(sleep_sec)
                Chef::Log.info "Requested tags are not available yet. Waiting for #{sleep_sec} seconds..."
                sleep sleep_sec

                Chef::Log.info "Re-querying for the requested tags..."
                tags_hash_array = query(query_string)
              end
            end
          end
        rescue Timeout::Error => e
          raise e, "Requested tags could not be found within #{timeout_sec} seconds"
        end
        return tags_hash_array
      end
    end

    private

    # Use the MachineTag.factory method to create this class.
    #
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
        # If there are more than one '=' sign in 'value, split the tag on the
        # first '=' sign
        namespace_predicate, value = split_tag(tag)
        t_hash[namespace_predicate] = value
      end
      t_hash
    end

    # Splits a tag into 'namespace:predicate' and 'value'.
    #
    # @param tag [String] the tag to be split
    #
    # @return [String] the 'namespace:predicate' and the 'value'
    #
    def split_tag(tag)
      # If there are more than one '=' sign in 'value, split the tag on the
      # first '=' sign
      tag.split('=', 2)
    end

    # Checks if a tag exists in the array of tag hashes.
    #
    # @param tags_hash_array [Array<Hash>] the array of tag hashes to be looked up
    # @param tag [String] the tag to search
    #
    # @return [Array] the array of tag hashes that contains the tag, otherwise
    # empty array if tag does not exist
    #
    # @raise [RuntimeError] if the queried tag is not a valid query
    #
    def detect_tag(tags_hash_array, tag)
      raise "#{tag} is not a valid tag query!" unless valid_tag_query?(tag)

      key, value = split_tag(tag)
      tags_hash_array.select do |tags_hash|
        # If tag value is a wildcard, select tags that match the namespace:predicate (key)
        # else, detect tags that match both namespace:predicate and the value
        if value == '*' || value.nil?
          tags_hash.keys.include?(key)
        else
          tags_hash.keys.include?(key) && tags_hash[key] == value
        end
      end
    end

    # Validates the tag passed into the query.
    #
    # @see http://support.rightscale.com/12-Guides/RightLink/01-RightLink_Overview/RightLink_Command_Line_Utilities#rs_tag
    #
    # @return [Boolean] true if the tag query is valid, false otherwise
    #
    def valid_tag_query?(tag)
      # See http://support.rightscale.com/12-Guides/RightScale_101/06-Advanced_Concepts/Tagging
      # for tag syntax rules.
      #
      tag =~ /^[a-zA-Z]\w*:[a-zA-Z]\w*(=(\*|.+[^*]))?$/
    end

    # Calculates the interval for re-querying tags. For every re-query the interval
    # is increased exponentially until the interval reaches the maximum limit of
    # MAX_SLEEP_INTERVAL.
    #
    # @param delay [Integer] the current sleep interval
    #
    # @return [Integer] the new sleep interval
    #
    def sleep_interval(delay = 1)
      return 2 if delay == 1
      [delay * delay, MAX_SLEEP_INTERVAL].min
    end

    # Raises an error if the method called is not implemented in the class.
    #
    # @raise [NotImplementedError] if the method call is not implemented
    #
    def not_implemented
      caller[0] =~ /`(.*?)'/
      raise NotImplementedError, "#{$1} is not implemented on #{self.class}"
    end
  end
end
