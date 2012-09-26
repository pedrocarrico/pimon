# encoding: UTF-8
require_relative 'probe'

class Probe::Temperature < Probe
  def self.check
    `cat /sys/class/thermal/thermal_zone0/temp`[0..1].to_i
  end
  
  def self.symbol
    :temp
  end
  
  def self.unit
    'ºC'
  end
end
