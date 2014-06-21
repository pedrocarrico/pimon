require_relative 'probe'

class Probe::CpuUsage < Probe
  def self.check
    100 - `vmstat 1 2`.split(/\n/)[3].split(" ")[14].to_i
  end
  
  def self.symbol
    :cpu
  end
end
