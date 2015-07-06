require_relative 'probe'
require_relative 'system_memory'

class Probe::SwapUsage < Probe
  def self.check
    SystemMemory.check(:swap)
  end

  def self.symbol
    :swap
  end
end
