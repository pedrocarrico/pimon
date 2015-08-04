module Pimon
  module Probe
    class DiskUsage
      def self.check(date = Time.now)
        value = `df`.split(/\n/)[1].split(' ')[4].to_i
        OpenStruct.new(date: date.strftime('%Y-%m-%d %H:%M:%S'), probe_name: 'disk', value: value, unit: unit)
      end

      def self.unit
        '%'
      end
    end
  end
end
