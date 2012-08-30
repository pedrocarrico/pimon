# As seen in https://gist.github.com/151324
module HashExtensions
  def symbolize_keys
    inject({}) do |acc, (k,v)|
      key = String === k ? k.to_sym : k
      value = Hash === v ? v.symbolize_keys : v
      acc[key] = value
      acc
    end
  end
end
Hash.send(:include, HashExtensions)
