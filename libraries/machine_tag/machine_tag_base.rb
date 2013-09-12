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

# TODO: investigate monkey-patching Chef::Search::Query to use `rs_tag` when
#       querying node:tags
#
# TODO: needs to support :mandatory_tags argument
#
# class Chef
#   class Search
#     class Query

#     end
#   end
# end

class Chef
  class MachineTagBase

    # create a tag for this server
    def create(tag)
      not_implemented
    end

    # delete a tag for this server
    def delete(tag)
      not_implemented
    end

    # List all the tags for this server
    def list
      not_implemented
    end

    # Return the list of tags for all server that match the query
    def search(query = nil, args = {})
      not_implemented
    end

    private

    # Use the MachineTag.factory method to create this class
    def initalize()
    end

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

    def not_implemented
      caller[0] =~ /`(.*?)'/
      raise NotImplementedError, "#{$1} is not implemented on #{self.class}"
    end

  end
end
