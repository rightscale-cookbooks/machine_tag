# machine_tag cookbook

[![Build Status](https://travis-ci.org/rightscale-cookbooks/machine_tag.png?branch=master)](https://travis-ci.org/rightscale-cookbooks/machine_tag)

This cookbook provides a `machine_tag` resource that can create, delete, list, and
search [machine tags][Tagging] in the Vagrant and RightScale environments. 

[Tagging]: http://support.rightscale.com/12-Guides/RightScale_101/06-Advanced_Concepts/Tagging

# Requirements

 * [machine_tag] gem which provides a library for using machine tags.

[machine_tag]: https://rubygems.org/gems/machine_tag

## Vagrant Environment

For using this resource in a *Vagrant environment* install the following

 * Vagrant 1.2+
 * Bindler

This resource detects a Vagrant environment when the `node['cloud']['provider']` is set to
`vagrant`. This value is set automatically when the `vagrant-ohai` plugin is installed.
For test-kitchen tests, we set this value in the `.kitchen.yml` file.

[Bindler][Bindler] is used to manage Vagrant plugins required by this resource.
See [Bindler README][Bindler] on how to setup bindler.

[Bindler]: https://github.com/fgrehm/bindler

The Vagrant plugins required by this resource to work on a Vagrant environment
is put inside `plugins.json` file in the root of the repository. Once Bindler is set
up, install these plugins by running

```
vagrant plugin bundle
```

Set a unique hostname for each VM in your Vagrantfile. To set this use the
`config.vm.host_name` configuration key:

```ruby
master.vm.host_name = "master"
```
See `Vagrantfile` for an example.

## RightScale Environment

For using this resource in a *RightScale Environment*, the system must be a
RightScale managed VM to have the required access to the [rs_tag utility][rs_tag].

[rs_tag]: http://support.rightscale.com/12-Guides/RightLink/01-RightLink_Overview/RightLink_Command_Line_Utilities#rs_tag


# Recipes

## default

Installs the [machine_tag] gem.


# Resource/Provider

## machine_tag

A resource to create and delete machine_tags on a VM.

### Action: create

Creates a new machine_tag on the VM.

#### Parameters

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>name</td>
    <td>Name of the tag to be created</td>
    <td></td>
  </tr>
</table>

### Action: delete

Deletes a machine_tag from the VM.

#### Parameters

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>name</td>
    <td>Name of the tag to be deleted</td>
    <td></td>
  </tr>
</table>


# Helpers

This resource also provides two helper methods for listing and searching tags on a VM.
To use them in a recipe have the following code block in the recipe

```ruby
class Chef::Recipe
  include Chef::MachineTagHelper
end
```

## tag_search(node, query, args)

Returns an array of tag hashes for all servers in your environment that matches the query.

### Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td>node</td>
    <td>the environment (Vagrant or RightScale)</td>
    <td><tt>Chef::Node</tt></td>
  </tr>
  <tr>
    <td>query</td>
    <td>the tags to be queried (multiple tags are space delimited)</td>
    <td><tt>String</tt></td>
  </tr>
  <tr>
    <td>options</td>
    <td>optional parameters to the query</td>
    <td><tt>Hash</tt></td>
  </tr>
</table>

## tag_list(node)

Returns a tag hash for the current server.

<table>
  <tr> 
    <th>Name</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td>node</td>
    <td>the environment (Vagrant or RightScale)</td>
    <td><tt>Chef::Node</tt></td>
  </tr>
</table>


# Usage

To create a machine_tag

```ruby
machine_tag "namespace:predicate=value" do
  action :create
end
```

To delete a machine_tag

```ruby
machine_tag "namespace:predicate=value" do
  action :delete
end
```

To list tags in the VM

```ruby
class Chef::Recipe
  include Chef::MachineTagHelper
end

tags = tag_list(node)
```

To search tags in the VM

```ruby
class Chef::Recipe
  include Chef::MachineTagHelper
end

tags = tag_search(node, 'test:tag=foo foo:bar=* some:tag')
```

# Attributes

* `node['machine_tag']['vagrant_tag_cache_dir']` - path to store the tag data for each server.
  Only used in Vagrant environments. This should match a `config.vm.synced_folder` entry in your Vagrantfile for
  `tag_search()` to work across VMs. See the `Vagrantfile` for an example.

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
