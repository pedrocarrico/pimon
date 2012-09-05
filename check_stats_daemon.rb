require 'bundler/setup'
ENV['RACK_ENV'] = 'development' unless ENV['RACK_ENV']
Bundler.require(:default, ENV['RACK_ENV'])

require "#{File.dirname(__FILE__)}/lib/pimon_config"
require "#{File.dirname(__FILE__)}/lib/stats_collector"
require 'redis'

Signal.trap('INT') do
  puts 'Exiting...'
  exit(0)
end

config = PimonConfig.create_new(ENV['RACK_ENV'])

stats_collector = StatsCollector.new(config, Redis.new(:path => config.redis[:socket]))

check_interval_in_secs = config.stats[:time_period_in_min] * 60

while true do
  puts "Checking stats at #{ Time.now.strftime("%Y-%m-%d %H:%M:%S") }"
  stats_collector.collect_stats
  sleep(check_interval_in_secs)
end
