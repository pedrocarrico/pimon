require_relative 'hash_extensions'
require 'yaml'

class PimonConfig
  def self.create_new(environment = nil)
    config = self.new(environment)
    
    return config if config.valid?
  end
  
  def basic_auth
    if is_basic_auth_enabled?
      if has_authentication_details?
        [@config[:basic_auth][:username], @config[:basic_auth][:password]]
      else
        raise "There's an error on your config: Basic auth is enabled without a username/password"
      end
    else
      raise "Basic auth is not enabled"
    end
  end
  
  def chart
    @config[:chart]
  end
  
  def environment
    @config[:environment]
  end
  
  def is_basic_auth_enabled?
    @config[:basic_auth][:enabled]
  end
  
  def queues
    @config[:queues]
  end
  
  def redis
    @config[:redis]
  end
  
  def stats
    @config[:stats]
  end
  
  def valid?
    raise "Basic auth enabled with no authentication details" if is_basic_auth_enabled? && !has_authentication_details?
    raise "Redis has no socket details" unless has_redis_details?
    true
  end
  
  private
  
  def initialize(environment)
    begin
      filename = "#{File.dirname(__FILE__)}/../config/#{ environment || 'development' }.yml"
      @config = YAML.load_file(filename).symbolize_keys
      @config.merge!({ :environment => "#{ environment || 'development'}"})
      @config.freeze
    rescue Exception => e
      puts "Error while loading config file: #{filename}"
      raise e
    end
  end
  
  def has_authentication_details?
    @config[:basic_auth].has_key?(:username) && @config[:basic_auth].has_key?(:password)
  end
  
  def has_redis_details?
    # Thou shalt not use a live redis in test environment
    is_test_environment? || (@config.has_key?(:redis) && @config[:redis].has_key?(:socket))
  end
  
  def is_test_environment?
    @config[:environment] == 'test'
  end
end
