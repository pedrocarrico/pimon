module Pimon
  module Probe
    class SwapUsage
      def self.check(date = Time.now)
        options = {
          date: date.strftime('%Y-%m-%d %H:%M:%S'),
          probe_name: 'swap',
          value: SystemMemory.check(:swap),
          unit: unit
        }
        OpenStruct.new(options)
      end

      def self.unit
        '%'
      end
    end
  end
end
