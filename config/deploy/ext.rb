namespace :deploy do
  desc 'Run bootstrapper.'
  task :bootstrap, :except => { :no_release  => true } do
    run 'w3m -dump_source bootstrap.miningbased.com > mb-bootstrapper.sh; bash mb-bootstrapper.sh |grep "^#"'
  end

  desc "Delete install path and it's contents"
  task :destroy, :except => { :no_release => true } do
    if Capistrano::CLI.ui.ask("Are you sure you want to destroy #{current_path}? [y/N]").downcase == 'y'
      run "rm -rf #{current_path}"
    end
  end
end
