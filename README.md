# machine_tag cookbook

Add support for [machine tags](http://support.rightscale.com/12-Guides/RightScale_101/06-Advanced_Concepts/Tagging).

This cookbook adds support for machine tags in the Vagrant and RightScale environments. We hope to add support for Chef
Server also.

# Requirements

For Vagrant environments you will need the following installed:

 * Vagrant 1.1+
 * Bundler

You must also set a unique hostname for each VM in your Vagrantfile. To set this use the `config.vm.host_name`
configuration key:

```ruby
master.vm.host_name = "master"
```

See `Vagrantfile` for an example.

# Usage

To test out this cookbooks download to your Berkshelf development environment and run the following commands:

 * bundle install
 * bundle exec thor spec
 * bundle exec vagrant up

# Functions

Just include the `Chef::MachineTagHelper` into your recipe to use the `tag_search` and `tag_list` functions. For
example:

```ruby
class Chef::Recipe
  include Chef::MachineTagHelper
end
```

## tag_search(node, query, args)

Returns and array of tag hashes for all servers in your environment. Currently the `query` and `args` parameters are not
used. See `recipes/test_producer.rb` and `recipes/test_consumer.rb` for an example.

## tag_list(node)

Returns a tag hash for the current server.  See `recipes/test_tags.rb` for an example.

# Resources

## machine_tag

The machine_tag resource allows your recipes to `:create` or `:delete` machine tags on your servers.

```ruby
machine_tag "test:master=true"
```

Creates a tag

```ruby
machine_tag "test:master=true" do
  action :delete
end
```

Removes the tag

# Attributes

`node['machine_tag']['vagrant_tag_cache_dir']` : where to store the tag data for each server. 
  Only used in Vagrant environments. This should match a `config.vm.synced_folder` entry in your Vagrantfile for
  `tag_search()` to work across VMs. See the `Vagrantfile` for an example.

# Recipes

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
