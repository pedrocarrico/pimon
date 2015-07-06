require 'sys/uptime'

require_relative 'probe'

class Probe::Uptime < Probe
  def self.check
    Sys::Uptime.dhms
  end

  def self.symbol
    :uptime
  end
end
