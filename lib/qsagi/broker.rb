module Qsagi
  class Broker
    attr_reader :connection, :channel, :exchange

    def initialize(config = nil)
      @config = config
    end

    def connect
      @connection = Bunny.new(
        host: @config[:host],
        port: @config[:port],
        vhost: @config[:vhost],
        user: @config[:user],
        password: @config[:password],
        heartbeat: @config[:heartbeat],
        automatically_recover: true,
        network_recovery_interval: 1
      )

      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.exchange(
        @config[:exchange],
        type: @config[:exchange_type],
        durable: true,
        auto_delete: false
      )
    end

    def disconnect
      @connection.close
      @connection, @channel, @exchange = nil, nil, nil
    end
  end
end
