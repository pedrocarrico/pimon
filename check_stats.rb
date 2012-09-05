require 'bundler/setup'
ENV['RACK_ENV'] = 'development' unless ENV['RACK_ENV']
Bundler.require(:default, ENV['RACK_ENV'])

require 'daemons'
require "#{File.dirname(__FILE__)}/lib/pimon_config"

config = PimonConfig.create_new(ENV['RACK_ENV'])

options = { :app_name => 'pimon_stats_collector',
            :backtrace => true,
            :dir => config.stats[:pid_dir],
            :dir_mode => :normal,
            :log_dir => config.stats[:log_dir],
            :log_output => true,
            :multiple => false,
            :ontop => !config.stats[:daemonize]
          }

Daemons.run('check_stats_daemon.rb', options)
