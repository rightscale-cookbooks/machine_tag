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
  class MachineTagRl10 < MachineTagBase

    include Chef::Mixin::ShellOut

    def initialize_api_client
      require "right_api_client"
      RightApi::Client.new(:rl10 => true)
    end
    
    def api_client
      @@api_client ||= initialize_api_client
    end
    
    # Creates a tag on the server.
    #
    # @param tag [String] the tag to be created
    #
    def create(tag)
      begin
        api_client.tags.multi_add(resource_href: api_client.index_instance_session.href, tags: [tag])
      rescue RightApi::ApiError => e
        puts e
      end
    end

    # Deletes a tag from the server.
    #
    # @param tag [String] the tag to be deleted
    #
    def delete(tag)
      api_client.tags.multi_delete(resource_href: api_client.index_instance_session.href, tags: [tag]) 
    end

    # Lists all tags on the server.
    #
    # @return [MachineTag::Set] the tags on the server
    #
    def list
      json = api_client.tags.by_resource(resource_href: api_client.index_instance_session.href)
      ::MachineTag::Set.new(JSON.parse(json))
    end


    protected

    # Searches for the given tags on the servers.
    #
    # @param query_tags [Array<String>] the tags to be queried
    #
    # @return [Array<MachineTag::Set>] the tags on the servers that match the query
    #
    def do_query(query_tags)
      json = api_client.tags.by_tag(resource_type: 'servers', tags: [query_tags] )
      tags_hash = JSON.parse(json)
      tags_set_array = []
      tags_hash.values.each do |value|
        tags_set_array << ::MachineTag::Set.new(value['tags'])
      end
      tags_set_array
    end
  end
end
