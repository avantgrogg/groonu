require "bundler/capistrano"

set :application, "groonu.com"
set :repository,  "https://github.com/forgetlines/groonu.git/trunk"
set :rvm_ruby_string, 'ruby-1.9.3-p194@groonu'
set :rvm_type, :user

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "groonu.com"                          # Your HTTP server, Apache/etc
role :app, "groonu.com"                          # This may be the same as your `Web` server
role :db,  "groonu.com", :primary => true # This is where Rails migrations will run

set :deploy_to, "/var/www/vhosts/groonu.com"  # CHANGE THIS LINE TO POINT TO THE CORRECT PATH
set :user, "root"  # CHANGE THIS LINE TO USE YOUR OCS USERNAME
set :use_sudo, false
set :port_number, "3001"

after "deploy:update_code", :link_production_db

namespace :deploy do
	
  task :start, :roles => :app do
    run "cd #{deploy_to}/current; passenger start -e production -p #{port_number} -d"
  end
  task :stop, :roles => :app do
    run "cd #{deploy_to}/current; passenger stop -p #{port_number}"
  end
  task :restart, :roles => :app do
    run "cd #{deploy_to}/current; passenger stop -p #{port_number}; passenger start -e production -p #{port_number} -d"
    run "echo \"WEBSITE HAS BEEN DEPLOYED\""
  end
end

# database.yml task
desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end