# frozen_string_literal: true
name             'machine_tag'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures machine_tag'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.4'
issues_url       'https://github.com/rightscale-cookbooks/machine_tag/issues' if respond_to?(:issues_url)
source_url       'https://github.com/rightscale-cookbooks/machine_tag' if respond_to?(:source_url)
chef_version     '>= 12.0' if respond_to?(:chef_version)

depends 'apt'
depends 'build-essential'
depends 'chef-sugar'

recipe 'machine_tag::default', "Installs the 'machine_tag' gem used by the helpers."
