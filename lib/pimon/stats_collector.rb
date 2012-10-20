require 'date'
require 'json'
require 'pimon/probe/cpu_usage'
require 'pimon/probe/disk_usage'
require 'pimon/probe/memory_usage'
require 'pimon/probe/swap_usage'
require 'pimon/probe/time_check'
require 'pimon/probe/temperature'
require 'pimon/stats'

class StatsCollector
  def initialize(config)
    @config = config
    @probes = [
      Probe::TimeCheck,
      Probe::CpuUsage,
      Probe::MemoryUsage,
      Probe::SwapUsage,
      Probe::DiskUsage,
      Probe::Temperature
    ]
    @stats = Stats.new(@probes.map(&:symbol).concat([:time]))
  end
  
  def collect_stats
    pop_old_stats
    
    @probes.each do |probe|
      @stats.push(probe.symbol, probe.check)
    end
  end
  
  def last_update
    time = @stats.index(:time, @config.stats[:number_of_stats] - 1)
    
    DateTime.parse(time) if time
  end
  
  def show_stats
    time = @stats.range(:time)
    
    stats = {
              :time => { :stats => time.map { |t| (/\d\d:\d\d:\d\d/.match(t))[0] } }
            }
    
    @probes.each do |probe|
      stats[probe.symbol] =
       { 
         :stats => @stats.range(probe.symbol).map(&:to_i),
         :color => @config.chart[probe.symbol][:color],
         :unit => probe.unit
       } unless probe.symbol == :time
    end
    
    stats.to_json
  end
  
  private
   
  def pop_all_queues
    @probes.each { |probe| @stats.shift(probe.symbol) }
  end
  
  def pop_old_stats
    queue_size = @stats.range(:time).length
    
    if queue_size >= @config.stats[:number_of_stats]
      (queue_size - @config.stats[:number_of_stats] + 1).times { pop_all_queues }
    end
  end
end
