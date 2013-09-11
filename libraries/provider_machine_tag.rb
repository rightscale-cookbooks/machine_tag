libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'chef/provider'
require 'resource_machine_tag'
require 'machine_tag_helper.rb'

class Chef
  class Provider
    class MachineTag < Chef::Provider

      def load_current_resource
        @current_resource = Chef::Resource::MachineTag.new(@new_resource.name)
        @tag_helper = get_helper(@run_context.node)
        @current_resource
      end

      def action_create
        @tag_helper.create(new_resource.name)
      end

      def action_delete
        @tag_helper.delete(new_resource.name)
      end

      private

      def get_helper(node)
        Chef::MachineTag.factory(node)
      end

    end
  end
end
