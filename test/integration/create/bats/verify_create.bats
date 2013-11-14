#!/usr/bin/env bats

@test "folder is created for the VM in the shared space" {
  ls /vagrant/cache_dir/machine_tag_cache/`hostname -s`
}

@test "machine tags for master are created" {
  cat /vagrant/cache_dir/machine_tag_cache/`hostname -s`/tags.json | \
    grep "master:ip=`/sbin/ifconfig eth0 | grep \"inet addr\" | awk -F: '{print $2}' | awk '{print $1}'`"
  cat /vagrant/cache_dir/machine_tag_cache/`hostname -s`/tags.json | \
    grep "master:hostname=`hostname -s`"
  cat /vagrant/cache_dir/machine_tag_cache/`hostname -s`/tags.json | \
    grep "master:login=restricted"
}
