require 'config/env'
require 'rake/testtask'
require 'mini/util/cli'
require 'socket'

include Mini::Util::CLI

rakefiles = Dir[File.join(MINI_ROOT, "lib/*/Rakefile")]
rakefiles.each do |rf| 
  load rf 
end

Rake::TestTask.new(:test) do |t|
  t.pattern = 'lib/**/test/**/test_*.rb'
end

task :default do
  Mini.banner("Welcome to:")
  puts IO.read('README.md')
end

namespace :mini do
  desc "Start Processes"
  task :start do
    puts "Starting the minor deity"
    `bundle exec god -c config/mini.god.rb`
  end

  desc "Restart Processes"
  task :restart => [:stop, :start] do
  end

  desc "Stop all mini processes"
  task :stop do
    puts "Stopping the minor deity"
    `bundle exec god terminate`
  end
end
