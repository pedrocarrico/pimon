require 'date'

require "pimon/probe/cpu_usage"
require "pimon/probe/disk_usage"
require "pimon/probe/memory_usage"
require "pimon/probe/swap_usage"
require "pimon/probe/temperature"

class StatsCollector
  def initialize(config, redis)
    @config = config
    @redis = redis
    @probes = [Probe::CpuUsage, Probe::MemoryUsage, Probe::SwapUsage, Probe::DiskUsage, Probe::Temperature]
  end
  
  def collect_stats
    pop_old_stats
    
    @redis.rpush(@config.queues[:time], Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    @probes.each do |probe|
      @redis.rpush(@config.queues[probe.symbol], probe.check)
    end
  end
  
  def last_update
    time = @redis.lindex(@config.queues[:time], @config.stats[:number_of_stats] - 1)
    
    DateTime.parse(time) if time
  end
  
  def show_stats
    time = @redis.lrange(@config.queues[:time], 0, -1)
    
    stats = {
              :time => { :stats => time.map { |t| (/\d\d:\d\d:\d\d/.match(t))[0] } },
              :refresh_interval_in_millis => @config.stats[:time_period_in_min] * 60 * 1000
            }
    
    @probes.each do |probe|
      stats[probe.symbol] =
       { 
         :stats => @redis.lrange(@config.queues[probe.symbol],  0, -1).map(&:to_i),
         :color => @config.chart[probe.symbol][:color],
         :unit => probe.unit
       }
    end
    
    stats
  end
  
  private
   
  def pop_all_queues
    @redis.lpop(@config.queues[:time])
    @probes.each { |probe| @redis.lpop(@config.queues[probe.symbol]) }
  end
  
  def pop_old_stats
    queue_size = @redis.llen(@config.queues[:time])
    
    if queue_size >= @config.stats[:number_of_stats]
      (queue_size - @config.stats[:number_of_stats] + 1).times { pop_all_queues }
    end
  end
end
