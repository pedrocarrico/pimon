require 'pimon/probe/probe'
require 'pimon/probe/system_memory'

class Probe::MemoryUsage < Probe
  
  def self.check
    SystemMemory.check(:mem)
  end
  
  def self.symbol
    :mem
  end
end
