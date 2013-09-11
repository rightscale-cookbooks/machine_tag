# TODO: investigate monkey-patching Chef::Search::Query to use `rs_tag` when
#       querying node:tags
#
# TODO: needs to suppport :mandiatory_tags argument
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
    def search(query=nil, args={})
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