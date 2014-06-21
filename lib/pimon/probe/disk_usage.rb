require_relative 'probe'

class Probe::DiskUsage < Probe
  def self.check
    `df`.split(/\n/)[1].split(" ")[4].to_i
  end
  
  def self.symbol
    :disk
  end
end
