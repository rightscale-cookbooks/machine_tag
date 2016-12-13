name             'machine_tag'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures machine_tag'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'
issues_url       'https://github.com/rightscale-cookbooks/machine_tag/issues'
source_url       'https://github.com/rightscale-cookbooks/machine_tag'

depends 'apt'
depends 'build-essential'

recipe 'machine_tag::default', "Installs the 'machine_tag' gem used by the helpers."
