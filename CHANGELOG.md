machine_tag Cookbook CHANGELOG
=======================

This file is used to list changes made in each version of the machine_tag cookbook.

v2.0.4
------
- Added docker support thru chef-sugar and vagrant provider
- updated travis tests to use kitchen-dokken

v2.0.3
------
- adding a matcher for cookbook test

v2.0.2
------
- adding in support for chef 12.18

v2.0.1
------
- pinning right_api_client to 1.6.2, because 1.6.3 requires json(2)

v2.0.0
------
- Add support for Chef 12

v1.2.1
------
- Only returns operational instances
- Only returns instances in the same cloud as the machine executing the call.

v1.2.0
------

- Added support for match_all and defaulting to false

v1.1.0
------

- Added support for RightLink 10

v1.0.9
------

- Fixed bug in run_rs_tag_util method not returning string output.

v1.0.8
------

- Network issues can cause `rs_tag` command to fail. Retries are done if command is initially unsuccessful.

v1.0.7
------

- Add testing for support of Ubuntu 14.04, CentOS 7.0, and RedHat Enterprise Linux 7.0.

v1.0.6
------

- Update tag validation regex. ([#13][])
- Update strainer gem version to 3.x

v1.0.5
------

- Update to [test-kitchen](http://rubygems.org/gems/test-kitchen) 1.2.1 and use the new concurrency flag. ([#12][])
- Make the Vagrant tag support act like RightScale where machine tags are only unique by namespace and predicate. ([#14][])

v1.0.4
------

- `Chef::MachineTag.factory` now checks for existence of `rs_tag` utility to detect RightScale environment. ([#10][])
- Document Ruby 1.9 support. ([#7][])
- Update `tag_search` documentation in README ([#9][])

v1.0.3
------

- Accommodate changes from [machine_tag (v1.1.3)](http://rubygems.org/gems/machine_tag) gem
- Add class methods in MachineTagHelper

v1.0.2
------

- Updated README
- Fix the already initialized constants warning
- Updated Vagrantfile to work with Vagrant 1.3.x

v1.0.1
------

- Fix for packaged cookbook on Chef community site (Pull Request [#3][])

v1.0.0
------

- Initial release

<!--- The following link definition list is generated by PimpMyChangelog --->
[#3]: https://github.com/rightscale-cookbooks/machine_tag/issues/3
[#7]: https://github.com/rightscale-cookbooks/machine_tag/issues/7
[#9]: https://github.com/rightscale-cookbooks/machine_tag/issues/9
[#10]: https://github.com/rightscale-cookbooks/machine_tag/issues/10
[#12]: https://github.com/rightscale-cookbooks/machine_tag/issues/12
[#13]: https://github.com/rightscale-cookbooks/machine_tag/issues/13
[#14]: https://github.com/rightscale-cookbooks/machine_tag/issues/14
