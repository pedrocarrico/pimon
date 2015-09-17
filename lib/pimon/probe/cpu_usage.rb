module Pimon
  module Probe
    class CpuUsage
      def self.check(date = Time.now)
        value = 100 - `vmstat 1 2`.split(/\n/)[3].split(' ')[14].to_i
        OpenStruct.new(date: date.strftime('%Y-%m-%d %H:%M:%S'), probe_name: 'cpu', value: value, unit: unit)
      end

      def self.unit
        '%'
      end
    end
  end
end
