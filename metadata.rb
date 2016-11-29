name             'machine_tag'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures machine_tag'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.2.2'

depends 'apt', '~> 3.0.0'
depends 'build-essential','~> 3.2.0'

recipe 'machine_tag::default', "Installs the 'machine_tag' gem used by the helpers."
