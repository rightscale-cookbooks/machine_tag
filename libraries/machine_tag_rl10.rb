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
      @api_client = initialize_api_client
    end
    
    # Creates a tag on the server.
    #
    # @param tag [String] the tag to be created
    #
    def create(tag)
      api_client.tags.multi_add(resource_hrefs: [api_client.get_instance.href], tags: [tag])
    end

    # Deletes a tag from the server.
    #
    # @param tag [String] the tag to be deleted
    #
    def delete(tag)
      api_client.tags.multi_delete(resource_hrefs: [api_client.get_instance.href], tags: [tag]) 
    end

    # Lists all tags on the server.
    #
    # @return [MachineTag::Set] the tags on the server
    #
    def list
      tags = api_client.tags.by_resource(resource_hrefs: 
          [api_client.get_instance.href]).first.tags
      ::MachineTag::Set.new(tags.map{|tag| tag["name"]})
    end


    protected

    # Searches for the given tags on the servers.
    #
    # @param query_tags [Array<String>] the tags to be queried
    #
    # @return [Array<MachineTag::Set>] the tags on the servers that match the query
    #
    def do_query(query_tags, options = {})
      query_tags = [query_tags] if query_tags.kind_of?(String)
      Chef::Log.info "Tagged query_tags: #{query_tags}"
      match_all = options.fetch(:match_all, false)
      resources = api_client.tags.by_tag(resource_type: 'instances', tags: query_tags, match_all: match_all)
      Chef::Log.info "Tagged resources: #{resources}"

      tags_hash = {}
      if resources.first
        links = resources.first.links
        if links
          links.each do |link|
            Chef::Log.info "Tagged Resource Cloud:#{link["href"].split('/')[0..3].join('/')}"
            if api_client.get_instance.show.cloud.href == link["href"].split('/')[0..3].join('/')
              if api_client.resource(link["href"]).state == 'operational'
                resource_tags = api_client.tags.by_resource(resource_hrefs:[link["href"]])#.first.tags
                tags_hash[link["href"]]={
                  "tags"=> resource_tags.first.tags.map{|tag| tag["name"]}
                }
              end
            end
          end
        end
      end
      tags_set_array = []
      tags_hash.values.each do |value|
        tags_set_array << ::MachineTag::Set.new(value['tags'])
      end
      tags_set_array
    end
  end
end
