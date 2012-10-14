set :application, "pimon"
set :user, "pi"

set :scm, :git

set :repository, "git://github.com/pedrocarrico/pimon.git"

set :deploy_to, '/home/pi/app/pimon'
set :deploy_via, :remote_cache # quicker checkouts from github

set :domain, 'raspberrypi'
role :app, domain
role :web, domain

set :runner, user
set :use_sudo, false

after 'deploy:update_code', 'deploy:bundle_install'

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && PIMON_CONFIG=#{deploy_to}/shared/production.yml nohup thin -C config/thin/config.yml -R config/config.ru start"
  end
  
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C config/thin/config.yml -R config/config.ru stop"
  end
  
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
  
  task :cold do
    deploy.update
    deploy.start
  end
  
  desc "run 'bundle install' to install Bundler's packaged gems for the current deploy"
  task :bundle_install, :roles => :app do
    run "cd #{deploy_to}/current && bundle install --without test development"
  end
end
