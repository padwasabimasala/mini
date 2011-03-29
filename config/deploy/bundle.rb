after "deploy:update_code", "bundle:install_if_needed"

install_cmd = "bundle install --gemfile #{current_path}/Gemfile --without test development"

namespace :bundle do
  task :install do
    run install_cmd
  end
  
  task :install_if_needed do
    run "cd #{current_path}; ruby -r config/env -e '' || #{install_cmd}" # Do bundle install if require config/env fails
  end
end
