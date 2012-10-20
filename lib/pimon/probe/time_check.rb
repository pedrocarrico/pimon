require 'pimon/probe/probe'

class Probe::TimeCheck < Probe
  def self.check
    Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def self.symbol
    :time
  end
end
