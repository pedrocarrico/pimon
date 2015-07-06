require_relative 'probe'
require_relative 'system_memory'

class Probe::MemoryUsage < Probe
  def self.check
    SystemMemory.check(:mem)
  end

  def self.symbol
    :mem
  end
end
