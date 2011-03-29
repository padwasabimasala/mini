# git style deploys
# https://github.com/blog/470-deployment-script-spring-cleaning
# https://gist.github.com/176754
def set_branch
  set :branch do
    branch = ENV['branch']
    tag = ENV['tag']
    raise StandardError.new("Choose either tag or branch not both!") if branch && tag
    branch || tag || 'master'
  end
end

namespace :deploy do
  desc "Deploy the MFer"
  task :default do
    update
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc 'Setup a GitHub-style deployment.'
  task :setup, :except => { :no_release => true } do
    run "git clone #{repository} #{current_path}"
  end

  desc 'Update the deployed code w/o doing symlink'
  task :update_code, :except => { :no_release => true } do
    set_branch # may set branch to a tag name
    run "cd #{current_path}; git reset -q --hard; git fetch -q origin; git checkout -q #{branch}; git pull -q "
  end

  namespace :rollback do
    desc 'Moves the repo back to the previous version of HEAD'
    task :repo, :except => { :no_release => true } do
      set :branch, 'HEAD@{1}'
      deploy.default
    end
    
    desc 'Rewrite reflog so HEAD@{1} will continue to point to at the next previous release.'
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end
    
    desc 'Rolls back to the previously deployed version.'
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end
