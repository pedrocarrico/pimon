require 'pimon/probe/cpu_freq'
require 'pimon/probe/cpu_usage'
require 'pimon/probe/disk_usage'
require 'pimon/probe/memory_usage'
require 'pimon/probe/swap_usage'
require 'pimon/probe/system_memory'
require 'pimon/probe/temperature'
require 'pimon/probe/uptime'

# Monkeypatching OpenStruct to render correct json in a probe sample
class OpenStruct
  def to_json(options)
    table.to_json(options)
  end
end
