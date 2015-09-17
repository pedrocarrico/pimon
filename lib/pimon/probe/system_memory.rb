module Pimon
  module Probe
    class SystemMemory
      TYPE_INDEX = {
        mem: 1,
        swap: 2
      }

      def self.check(type)
        memory = `free -o -m`.split(/\n/)[TYPE_INDEX[type]].split(' ')

        return 0 if memory[1].to_i == 0
        # memory[1] holds total memory
        # memory[2] holds used memory
        ((memory[2].to_f / memory[1].to_f) * 100).to_i
      end
    end
  end
end
