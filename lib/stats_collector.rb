require 'date'

class StatsCollector
  def initialize(config, redis)
    @config = config
    @redis = redis
  end
  
  def collect_stats
    pop_old_stats
    
    @redis.pipelined do
      
      cpu_usage, mem_usage, swap_usage = check_stats
      
      @redis.rpush(@config.queues[:time], Time.now.strftime("%Y-%m-%d %H:%M:%S"))
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
    cpu_idle = vmstat[3].split(" ")[14].to_i
    mem = free
    ram = mem[1].split(" ")
    swap = mem[2].split(" ")
    
    mem_total  = ram[1].to_i
    mem_used   = ram[2].to_i
    swap_total = swap[1].to_i
    swap_used  = swap[2].to_i
    
    [ 100 - cpu_idle , calculate_percentage(mem_used, mem_total), calculate_percentage(swap_used, swap_total) ]
  end
  
  def free
    `free -o -m`.split(/\n/)
  end
  
  def pop_old_stats
    queue_size = @redis.llen(@config.queues[:time])
    
    while queue_size >= @config.stats[:number_of_stats]
      @redis.lpop(@config.queues[:time])
      @redis.lpop(@config.queues[:cpu])
      @redis.lpop(@config.queues[:mem])
      @redis.lpop(@config.queues[:swap])
      queue_size -= 1
    end
  end
  
  def vmstat
    `vmstat 1 2`.split(/\n/)
  end
end
