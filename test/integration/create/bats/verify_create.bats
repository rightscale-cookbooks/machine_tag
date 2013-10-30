#!/usr/bin/env bats

@test "folder is created for the VM in the shared space" {
  ls /vagrant/cache_dir/machine_tag_cache/`hostname -s`
}

@test "machine tag is created" {
  cat /vagrant/cache_dir/machine_tag_cache/`hostname -s`/tags.json | grep "test:tag=true"
}
