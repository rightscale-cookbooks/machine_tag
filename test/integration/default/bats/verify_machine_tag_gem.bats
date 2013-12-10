#!/usr/bin/env bats

@test "machine_tag gem is installed in the chef ruby sandbox" {
  # work around GEM_HOME being set in the busser environment and interfering with the test
  unset GEM_HOME
  /opt/chef/embedded/bin/gem list 'machine_tag' | grep -c 'machine_tag'
}
