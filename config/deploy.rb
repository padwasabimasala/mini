# http://help.github.com/capistrano/
# https://github.com/leehambley/capistrano-handbook/blob/master/index.markdown
# https://github.com/robinbowes/railsless-deploy
set :user, 'root'
set :application, 'mini'
set :scm, :git
set :repository,  'git://git.miningbased.com/mini/'
set :deploy_to, "/var/www/apps/#{application}"
set :branch, 'master' # Overridden by set_branch in git_deploy.rb

# loads must occur after params are set
load 'config/deploy/git'
load 'config/deploy/ext'
load 'config/deploy/bundle'

# proc restart?
# migrations?
# is railsless-deploy necessary?
