require File.join(File.dirname(__FILE__),"machine_tag","machine_tag_base.rb")
require File.join(File.dirname(__FILE__),"machine_tag","machine_tag_rightscale.rb")
require File.join(File.dirname(__FILE__),"machine_tag","machine_tag_vagrant.rb")

class Chef
  class MachineTag

    # factory method for instantiating the correct machine tag class
    # base on hints from the chef node
    def self.factory(node)
      # TODO: find a better way to detect operating environment
      if node.has_key?('rightscale')
        Chef::MachineTagRightscale.new
      elsif node.has_key?('vagrant')
        box_name, cache_dir = vagrant_params_from_node(node)
        Chef::MachineTagVagrant.new(box_name, cache_dir)
      else
        raise "ERROR: could not detect a supported machine tag environment."
      end
    end

    private

    # Use the factory method to create MachineTag class
    def initalize()
    end

    # harvest params from chef node with error checking
    def self.vagrant_params_from_node(node)
      # Verify box_name
      box_name = node['vagrant']['box_name']
      err_msg = "ERROR: node['vagrant']['box_name'] not defined. " + readme_info
      arg_error(err_msg) unless box_name

      # Veify machine_tag hash
      err_msg = "ERROR: node['machine_tag'] hash not defined. " + readme_info
      arg_error(err_msg) unless node.has_key?('machine_tag')

      # Vefiy cache_dir
      cache_dir = node['machine_tag']['vagrant_tag_cache_dir']
      err_msg = "ERROR: node['machine_tag']['vagrant_tag_cache_dir'] " +
                "not defined. " + readme_info
      arg_error(err_msg) unless cache_dir

      return box_name,cache_dir
    end

    def self.readme_info
      "Please see the README file in the 'machine_tag' cookbook."
    end

    def self.arg_error(message)
      raise ArgumentError.new(message)
    end

  end

  module MachineTagHelper
    def tag_search(node, query=nil, args={})
      Chef::MachineTag.factory(node).search(query, args)
    end

    def tag_list(node)
      Chef::MachineTag.factory(node).list
    end
  end

end