# frozen_string_literal: true
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
    # Default query timeout (in seconds)
    #
    DEFAULT_QUERY_TIMEOUT = 120 unless const_defined?(:DEFAULT_QUERY_TIMEOUT)

    # Maximum value for sleep interval (in seconds) when re-querying tags
    #
    MAX_SLEEP_INTERVAL = 60 unless const_defined?(:MAX_SLEEP_INTERVAL)

    # Creates a tag for this server.
    #
    # @param tag [String] the tag to create
    #
    def create(_tag)
      not_implemented
    end

    # Deletes a tag for this server.
    #
    # @param tag [String] the tag to delete
    #
    def delete(_tag)
      not_implemented
    end

    # Lists all the tags for this server.
    #
    # @return [MachineTag::Set] the list of tags
    #
    def list
      not_implemented
    end

    # Returns the list of tags for all server that match the query.
    #
    # @param query_tags [String, Array<String>] the tag or list of tags to search for
    #
    # @option options [Array<String>] :required_tags the tags that should be found by the query.
    #   If the tags are not found at the time of the query, re-query until they are found or the timeout is reached
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Array<MachineTag::Set>] the array of all tags on the servers that
    #   match the query
    #
    # @raise [Timeout::Error] if the required tags could not be found within the time
    #
    def search(query_tags, options = {})
      query_tags = [query_tags] if query_tags.is_a?(String)
      tags_set_array = do_query(query_tags, options)

      unless options[:required_tags].nil? || options[:required_tags].empty?
        # Set timeout for querying for required_tags. By default, the timeout is set
        # for 120 seconds if no timeouts specified.
        query_timeout = options[:query_timeout] ? options[:query_timeout] : DEFAULT_QUERY_TIMEOUT

        begin
          Timeout.timeout(query_timeout) do
            options[:required_tags].each do |tag|
              sleep_sec = 1
              # Check if the tag is found in all the servers in the query result. If not, re-query
              while detect_tag(tags_set_array, tag).length != tags_set_array.length
                # Calculate wait interval for re-querying
                sleep_sec = sleep_interval(sleep_sec)
                Chef::Log.info "'#{tag}' is not available yet. Waiting for #{sleep_sec} seconds..."
                Kernel.sleep(sleep_sec)

                Chef::Log.info "Re-querying for '#{tag}'..."
                tags_set_array = do_query(query_tags, options)
              end
            end
          end
        rescue Timeout::Error => e
          raise e, "Requested tags could not be found within #{query_timeout} seconds"
        end
      end
      tags_set_array
    end

    protected

    # Queries for a specific tag on all servers and returns all the tags on the servers
    # that match the query.
    #
    # @param query_tags [Array<String>] the tags to be queried
    #
    # @return [Array<MachineTag::Set>] the list of all tags on the servers that match the query
    #
    def do_query(_query_tags, _options = {})
      not_implemented
    end

    private

    # Use the MachineTag.factory method to create this class.
    #
    def initalize; end

    # Checks if a tag exists in the array of tag sets.
    #
    # @param tags_set_array [Array<MachineTag::Set>] the array of tag hashes
    #   to be looked up
    # @param tag [String] the tag to search
    #
    # @return [Array<MachineTag::Set>] the array of tag sets that contains the tag, otherwise
    # empty array if tag does not exist
    #
    # @raise [RuntimeError] if the queried tag is not a valid query
    #
    def detect_tag(tags_set_array, tag)
      tag = ::MachineTag::Tag.new(tag)
      raise "#{tag} is not a valid tag query!" unless valid_tag_query?(tag)

      tags_set_array.select do |tags_set|
        if tag.machine_tag?
          if tag.value.include?('*')
            !tags_set[tag.namespace_and_predicate].empty?
          else
            tags_set.include?(tag)
          end
        else
          !tags_set[tag].empty?
        end
      end
    end

    # Validates the given tag with the machine tag regex rules.
    #
    # @param tag [MachineTag::Tag] the tag to be validated
    #
    # @see http://support.rightscale.com/12-Guides/RightLink/01-RightLink_Overview/RightLink_Command_Line_Utilities#rs_tag
    #   rs_tag Command Line Utility
    #
    # @return [Boolean] true if the tag query is valid, false otherwise
    #
    def valid_tag_query?(tag)
      if tag.machine_tag?
        return false if tag.value.include?('*') && tag.value != '*'
      else
        return false unless tag =~ /^#{::MachineTag::NAMESPACE_AND_PREDICATE}$/
      end
      true
    end

    # Calculates the interval for re-querying tags. For every re-query the interval
    # is increased exponentially until the interval reaches the maximum limit of
    # `MAX_SLEEP_INTERVAL`.
    #
    # @param delay [Integer] the current sleep interval
    #
    # @return [Integer] the new sleep interval
    #
    def sleep_interval(delay)
      return 2 if delay == 1
      [delay * delay, MAX_SLEEP_INTERVAL].min
    end

    # Raises an error if the method called is not implemented in the class.
    #
    # @raise [NotImplementedError] if the method call is not implemented
    #
    def not_implemented
      caller[0] =~ /`(.*?)'/
      raise NotImplementedError, "#{Regexp.last_match(1)} is not implemented on #{self.class}"
    end
  end
end
