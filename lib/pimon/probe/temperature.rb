module Pimon
  module Probe
    class Temperature
      def self.check(date = Time.now)
        value = `cat /sys/class/thermal/thermal_zone0/temp`[0..1].to_i
        OpenStruct.new(date: date.strftime('%Y-%m-%d %H:%M:%S'), probe_name: 'temp', value: value, unit: unit)
      end

      def self.unit
        'ºC'
      end
    end
  end
end
