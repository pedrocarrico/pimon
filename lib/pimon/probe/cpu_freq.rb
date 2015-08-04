module Pimon
  module Probe
    class CpuFreq
      def self.check(date = Time.now)
        value = `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`.to_i / 1000
        OpenStruct.new(date: date.strftime('%Y-%m-%d %H:%M:%S'), probe_name: 'cpu_freq', value: value, unit: unit)
      end

      def self.unit
        'Mhz'
      end
    end
  end
end
