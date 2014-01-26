module Qsagi
  class Config
    def initialize(config={})
      @config = default_config.merge(config)
    end

    def broker_options
      {
        host: @config[:host],
        port: @config[:port],
        vhost: @config[:vhost],
        user: @config[:user],
        password: @config[:password],
        heartbeat: @config[:heartbeat],
        automatically_recover: @config[:automatically_recover],
        network_recovery_interval: @config[:network_recovery_interval]
      }
    end

    def exchange_options
      {
        type: @config[:exchange][:type],
        durable: true,
        auto_delete: false
      }
    end

    def exchange_name
      @config[:exchange][:name]
    end

    private
    def default_config
      {
        vhost: "/",
        host: "127.0.0.1",
        port: "5672",
        user: "guest",
        password: "guest",
        heartbeat: :server,
        exchange: {name: "", type: :topic},
        logger: Logger.new($stdout),
        network_recovery_interval: 1,
        automatically_recover: true
      }
    end
  end
end
