require 'ostruct'

module Configuration
  class Options < OpenStruct
    def initialize(values)
      super(values.params)
    end
  end

  def application_root
    set :root, File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  end

  def logger
    $access_logger
  end

  def configure_logging
    enable :logging
    use ::Rack::CommonLogger, $access_logger
    
    ::Logger.class_eval { alias :write :'<<' }
    access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', '..', 'log', 'access.log')
    $access_logger = ::Logger.new(access_log)
    $error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', '..', 'log', 'error.log'), "a+")
    $error_logger.sync = true
  end

  def configure_redis
    $redis = Redis.new(:host => @config.redis_host, :port => @config.redis_post)
  end

  def configure_app
    config_file_path = File.join(File.dirname(__FILE__), '..', '..', 'config', 'server.conf').chomp
    config_options = ParseConfig.new(config_file_path)
    @config = Options.new(config_options)

    application_root
    configure_logging

    mime_type :tei, 'application/tei+xml'
    enable :cross_origin

    set :bind, @config.host
    set :port, @config.port
  end
end
