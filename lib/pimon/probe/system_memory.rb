class SystemMemory
  
  def self.check(type)
    case type
    when :mem
      index = 1
    when :swap
      index = 2
    else
      raise "Undefined memory type: #{type}"
    end
    
    memory = `free -o -m`.split(/\n/)[index].split(" ")
    
    return 0 if memory[1].to_i == 0
    # memory[1] holds total memory
    # memory[2] holds used memory
    ((memory[2].to_f / memory[1].to_f) * 100).to_i
  end
end
