require './lib/pimon_config'
require './lib/stats_collector'
require 'redis'

ENV['RACK_ENV'] = 'development' unless ENV['RACK_ENV']

config = PimonConfig.create_new(ENV['RACK_ENV'])

StatsCollector.new(config, Redis.new(:path => config.redis['socket'])).collect_stats
