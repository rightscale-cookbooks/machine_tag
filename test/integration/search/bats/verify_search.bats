#!/usr/bin/env bats

@test "machine tags are searched" {
  ip="`/sbin/ifconfig eth0 | grep \"inet addr\" | awk -F: '{print $2}' | awk '{print $1}'`"
  host_name="`hostname -s`"

  grep -B 3 "ruby_block\[searching master tags\] called" /var/log/chef-solo.log | \
    grep "Master IP: $ip"
  grep -B 2 "ruby_block\[searching master tags\] called" /var/log/chef-solo.log | \
    grep "Master Hostname: $host_name"
  grep -B 1 "ruby_block\[searching master tags\] called" /var/log/chef-solo.log | \
    grep "Master Login State: restricted"
}
