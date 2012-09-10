require 'date'

class StatsCollector
  def initialize(config, redis)
    @config = config
    @redis = redis
  end
  
  def collect_stats
    pop_old_stats
    
    time, cpu_usage, mem_usage, swap_usage = check_stats
    
    @redis.pipelined do
      @redis.rpush(@config.queues[:time], time)
      @redis.rpush(@config.queues[:cpu], cpu_usage)
      @redis.rpush(@config.queues[:mem], mem_usage)
      @redis.rpush(@config.queues[:swap], swap_usage)
    end
  end
  
  def last_update
    time = @redis.lindex(@config.queues[:time], @config.stats[:number_of_stats] - 1)
    
    DateTime.parse(time) if time
  end
  
  def show_stats
    time, cpu, mem, swap = @redis.pipelined do
      @redis.lrange(@config.queues[:time], 0, -1)
      @redis.lrange(@config.queues[:cpu],  0, -1)
      @redis.lrange(@config.queues[:mem],  0, -1)
      @redis.lrange(@config.queues[:swap], 0, -1)
    end
    
    time = time.map { |t| (/\d\d:\d\d:\d\d/.match(t))[0] }
    cpu  = cpu.map(&:to_i)
    mem  = mem.map(&:to_i)
    swap = swap.map(&:to_i)
    
    o = {}
    o.merge!(@config.chart)
    o[:time] = {}
    o[:time][:stats] = time
    o[:cpu][:stats] = cpu
    o[:mem][:stats] = mem
    o[:swap][:stats] = swap
    o[:refresh_interval_in_millis] = @config.stats[:time_period_in_min] * 60 * 1000
    o
  end
  
  private
  
  def calculate_percentage(used, total)
    ((used.to_f / total) * 100).to_i
  end
  
  def check_stats
    mem_total, mem_used, swap_total, swap_used = free
    
    [ Time.now.strftime("%Y-%m-%d %H:%M:%S"), 100 - cpu_idle , calculate_percentage(mem_used, mem_total), calculate_percentage(swap_used, swap_total) ]
  end
  
  def cpu_idle
    vmstat[3].split(" ")[14].to_i
  end
  
  def free
    output = `free -o -m`.split(/\n/)
    
    mem = output[1].split(" ")
    swap = output[2].split(" ")
    
    [mem[1].to_i, mem[2].to_i , swap[1].to_i, swap[2].to_i]
  end
  
  def pop_all_queues
    @config.queues.each_value { |queue| @redis.lpop(queue) }
  end
  
  def pop_old_stats
    queue_size = @redis.llen(@config.queues[:time])
    
    if queue_size >= @config.stats[:number_of_stats]
      (queue_size - @config.stats[:number_of_stats] + 1).times { pop_all_queues }
    end
  end
  
  def vmstat
    # The second result of vmstat is more accurate
    `vmstat 1 2`.split(/\n/)
  end
end
