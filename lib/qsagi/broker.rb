module Qsagi
  class Broker
    attr_reader :connection, :channel, :exchange

    def initialize(config = {})
      @config = Qsagi::Config.new(config)
    end

    def connect
      @connection = Bunny.new(@config.broker)

      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.exchange(@config.exchange)
    end

    def disconnect
      @connection.close
      @connection, @channel, @exchange = nil, nil, nil
    end
  end
end
