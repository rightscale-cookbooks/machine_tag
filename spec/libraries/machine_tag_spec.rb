require File.join(File.dirname(__FILE__),"..","spec_helper.rb")

describe Chef::MachineTag do

  before(:all) do
    @vagrant_node = {
      'vagrant' => {'box_name' => 'mybox'},
      'machine_tag' => {'vagrant_tag_cache_dir' => '/vagrant/machine_tag_cache/'}
    }
  end

  describe "vagrant_params_from_node" do
    it "returns cache_dir and box_name" do
      box_name, cache_dir = Chef::MachineTag.vagrant_params_from_node(@vagrant_node)
      cache_dir.should == '/vagrant/machine_tag_cache/'
      box_name.should == 'mybox'
    end

    it "errors if box name is not found" do
      b0rked_node = {
        'vagrant' => {},
        'machine_tag' => {'vagrant_tag_cache_dir' => '/vagrant/machine_tag_cache/'}
      }
      lambda{ Chef::MachineTag.vagrant_params_from_node(b0rked_node)}.should raise_error(ArgumentError)
    end

    it "errors if box name is not found" do
      b0rked_node = {
        'vagrant' => {'box_name' => 'mybox'},
        'machine_tag' => {}
      }
      lambda{ Chef::MachineTag.vagrant_params_from_node(b0rked_node)}.should raise_error(ArgumentError)
    end

    it "errors if node['machine_tag'] is not defined" do
      b0rked_node = {
        'vagrant' => {'box_name' => 'mybox'}
      }
      lambda{ Chef::MachineTag.vagrant_params_from_node(b0rked_node)}.should raise_error(ArgumentError)
    end
  end

  describe "factory" do
    it "raises if it can't create a class" do
      lambda{Chef::MachineTag.factory({})}.should raise_error
    end

    it "returns a MachineTagRightscale class" do
      clazz = Chef::MachineTag.factory({"rightscale"=>{}})
      clazz.is_a?(Chef::MachineTagRightscale).should == true
    end

    it "returns a MachineTagVagrant class" do
      clazz = Chef::MachineTag.factory(@vagrant_node)
      clazz.is_a?(Chef::MachineTagVagrant).should == true
    end

    it "returns a MachineTagChefServer class"

  end

end

=begin
$ sudo rs_tag --list
[
  "appserver:active=true",
  "appserver:listen_ip=10.254.84.76",
  "appserver:listen_port=8000",
  "rs_login:state=restricted",
  "rs_monitoring:state=active",
  "server:private_ip_0=10.254.84.76",
  "server:public_ip_0=54.214.187.99",
  "server:uuid=01-6P781RDGU1F13"
]
=end

