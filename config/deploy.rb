default_run_options[:pty] = true

set :application, "pixie.strd6.com"

set :scm, "git"
set :repository, "git://github.com/STRd6/#{application}.git"
set :branch, "master"
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

ssh_options[:port] = 2112

role :app, "67.207.139.110"
role :web, "67.207.139.110"
role :db,  "67.207.139.110", :primary => true

after "deploy", "deploy:cleanup"

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

task :after_setup do
  run "mkdir #{shared_path}/production"
  run "mkdir #{shared_path}/production/images"
  run "mkdir #{shared_path}/db"
  run "mkdir #{shared_path}/backups"
  run "mkdir #{shared_path}/local"
  run "touch #{shared_path}/log/nginx.log"
  run "touch #{shared_path}/log/nginx.error.log"
end

task :after_update_code do
  run "ln -nfs #{shared_path}/production #{release_path}/public/production"
  run "ln -nfs #{shared_path}/local/authlogic.yml #{release_path}/config/authlogic.yml"
  run "ln -nfs #{shared_path}/local/local.rake #{release_path}/lib/tasks/local.rake"
end

# Passenger start Tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
