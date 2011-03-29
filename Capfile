#!/usr/bin/env ruby
# https://github.com/leehambley/capistrano-handbook/blob/master/index.markdown
require File.dirname(__FILE__) + '/config/env'
require 'railsless-deploy'
load 'config/deploy'
load 'config/roles'


task :uname do
  run 'uname -a'
end

#require 'uri'
namespace :mini do
  def rake_mini(cmd)
    run "cd #{current_path}; export MINI_ENV=#{Mini.env}; rake mini:#{cmd}"
  end

  desc "start"
  task :start do
    rake_mini("start")
  end 
  
  desc "restart"
  task :restart do
    rake_mini("restart")
  end 
  
  desc "stop"
  task :stop do
    rake_mini("stop")
  end

  task :halt do 
    rake_mini("halt")
  end
end
