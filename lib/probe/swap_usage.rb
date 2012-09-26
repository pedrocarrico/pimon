require_relative 'probe'

class Probe::SwapUsage < Probe
  def self.check
    output = `free -o -m`.split(/\n/)
    swap = output[2].split(" ")
    
    # swap[1] holds total swap
    # swap[2] holds used swap
    ((swap[2].to_f / swap[1].to_f) * 100).to_i
  end
  
  def self.symbol
    :swap
  end
end
