#!/usr/bin/env bats

@test "machine tags are listed" {
  ip="`/sbin/ifconfig eth0 | grep \"inet addr\" | awk -F: '{print $2}' | awk '{print $1}'`"
  host_name="`hostname -s`"

  grep -B 1 "ruby_block\[listing master tags\] called" /var/log/chef-solo.log | \
    grep "master:ip=$ip"
  grep -B 1 "ruby_block\[listing master tags\] called" /var/log/chef-solo.log | \
    grep "master:hostname=$host_name"
  grep -B 1 "ruby_block\[listing master tags\] called" /var/log/chef-solo.log | \
    grep "master:login=restricted"
}
