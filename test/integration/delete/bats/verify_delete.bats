#!/usr/bin/env bats

@test "machine tag is deleted" {
  cat /vagrant/cache_dir/machine_tag_cache/`hostname -s`/tags.json |
    grep -c "master:login=restricted" | grep "0"
}
