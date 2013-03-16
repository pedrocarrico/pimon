require 'pimon/probe/probe'
require 'sys/uptime'

class Probe::Uptime < Probe
  
  def self.check
    Sys::Uptime.dhms
  end
  
  def self.symbol
    :uptime
  end
end
