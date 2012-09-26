require_relative 'probe'

class Probe::MemoryUsage < Probe
  def self.check
    output = `free -o -m`.split(/\n/)
    
    mem = output[1].split(" ")
    
    # mem[1] holds total memory
    # mem[2] holds used memory
    ((mem[2].to_f / mem[1].to_f) * 100).to_i
  end
  
  def self.symbol
    :mem
  end
end
