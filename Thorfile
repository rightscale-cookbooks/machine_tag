# encoding: utf-8

require 'bundler'
require 'bundler/setup'
require 'thor/foodcritic'
require 'berkshelf/thor'

begin
  require 'kitchen/thor_tasks'
  Kitchen::ThorTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end

class Default < Thor
  include Thor::RakeCompat

  desc "spec", "Run RSpec code examples"
  def spec
    exec "rspec --color --format=documentation spec"
  end
end
