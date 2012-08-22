set :application, "pimon"
set :user, "pi"

set :scm, :git

set :repository, "git://github.com/pedrocarrico/pimon.git"

set :deploy_to, "/home/pi/app/pimon"
set :deploy_via, :remote_cache # quicker checkouts from github

set :domain, 'raspberrypi'
role :app, domain
role :web, domain

set :runner, user
set :use_sudo, false

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C config/thin/config.yml -R config/config.ru start"
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
end