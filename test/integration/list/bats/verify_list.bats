#!/usr/bin/env bats

@test "machine tags are listed" {
  grep -B 1 "ruby_block\[listing master tags\] called" /var/log/chef-solo.log | \
    grep "\"master:ip\"=>\"`/sbin/ifconfig eth0 | grep \"inet addr\" | awk -F: '{print $2}' | awk '{print $1}'`\""
  grep -B 1 "ruby_block\[listing master tags\] called" /var/log/chef-solo.log | \
    grep "\"master:hostname\"=>\"`hostname -s`\""
  grep -B 1 "ruby_block\[listing master tags\] called" /var/log/chef-solo.log | \
    grep "\"master:login\"=>\"restricted\""
}
