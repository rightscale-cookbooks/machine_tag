#!/usr/bin/env bats

@test "machine tags are searched" {
  grep -B 3 "ruby_block\[searching master tags\] called" /var/log/chef-solo.log | \
    grep "Master IP: `/sbin/ifconfig eth0 | grep \"inet addr\" | awk -F: '{print $2}' | awk '{print $1}'`"
  grep -B 2 "ruby_block\[searching master tags\] called" /var/log/chef-solo.log | \
    grep "Master Hostname: `hostname -s`"
  grep -B 1 "ruby_block\[searching master tags\] called" /var/log/chef-solo.log | \
    grep "Master Login State: restricted"
}
