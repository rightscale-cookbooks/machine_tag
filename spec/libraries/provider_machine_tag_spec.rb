
require File.join(File.dirname(__FILE__),"..","..","libraries","provider_machine_tag.rb")
require "chef"


describe Chef::MachineTag do

  before(:each) do
    @tag = "test:foo=bar"
    @vagrant_node = {
      'vagrant' => { 'box_name' => 'mybox' },
      'machine_tag' => { 'vagrant_tag_cache_dir' => '/vagrant/machine_tag_cache/' }
    }
    @node = Chef::Node.new
    @node.default['vagrant']['box_name'] = 'mybox'
    @node.default['machine_tag']['vagrant_tag_cache_dir'] = '/vagrant/machine_tag_cache/'
    @run_context = Chef::RunContext.new(@node, {}, nil)
  end

  it "creates a tag" do
    @new_resource = Chef::Resource::MachineTag.new(@tag)
    @provider = Chef::Provider::MachineTag.new(@new_resource, @run_context)
    helper_stub = stub("helper", :create => true)
    @provider.should_receive(:get_helper).and_return(helper_stub)
    @provider.load_current_resource
    helper_stub.should_receive(:create).and_return(true)
    @provider.action_create
  end

  it "deletes a tag" do
    @new_resource = Chef::Resource::MachineTag.new(@tag)
    @provider = Chef::Provider::MachineTag.new(@new_resource, @run_context)
    helper_stub = stub("helper", :delete => true)
    @provider.should_receive(:get_helper).and_return(helper_stub)
    @provider.load_current_resource
    helper_stub.should_receive(:delete).and_return(true)
    @provider.action_delete
  end

end



