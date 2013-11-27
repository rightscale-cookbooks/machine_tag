#!/usr/bin/env bats

@test "machine_tag gem is installed in the chef ruby sandbox" {
  unset GEM_HOME
  /opt/chef/embedded/bin/gem list 'machine_tag' | grep -c 'machine_tag'
}
