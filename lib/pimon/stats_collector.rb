require 'date'
require 'json'

require_relative 'probe/cpu_usage'
require_relative 'probe/disk_usage'
require_relative 'probe/memory_usage'
require_relative 'probe/swap_usage'
require_relative 'probe/time_check'
require_relative 'probe/temperature'
require_relative 'probe/uptime'
require_relative 'stats'

class StatsCollector
  attr_accessor :probes
  attr_accessor :last_update

  def initialize(config)
    @config = config
    @probes = [
      Probe::TimeCheck,
      Probe::CpuUsage,
      Probe::MemoryUsage,
      Probe::SwapUsage,
      Probe::DiskUsage,
      Probe::Temperature,
      Probe::Uptime
    ]
    @stats = Stats.new(@probes.map(&:symbol).concat([:time]))
  end
  
  def collect_stats
    pop_old_stats
    
    last_update = Time.now
    @probes.each do |probe|
      @stats.push(probe.symbol, probe.check)
    end
  end
  
  def show_stats
    time = @stats.range(:time)
    uptime = @stats.range(:uptime)
    
    stats = {
      :time => { :stats => time.map { |t| (/\d\d:\d\d:\d\d/.match(t))[0] } },
      :hostname => @config.hostname,
      :uptime => uptime
    }
    
    @probes.each do |probe|
      stats[probe.symbol] = {
        :stats => @stats.range(probe.symbol),
        :color => @config.chart[probe.symbol][:color],
        :unit => probe.unit
      } unless [:time, :uptime].include?(probe.symbol)
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
