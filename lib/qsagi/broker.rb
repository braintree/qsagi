module Qsagi
  class PublishError < StandardError; end

  class Broker
    attr_reader :connection, :channel, :exchange

    def initialize(config = {})
      @config = Qsagi::Config.new(config)
    end

    def connect
      @connection = Bunny.new(@config.broker)

      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.exchange(@config.exchange_name, @config.exchange)
    end

    def disconnect
      @connection.close
      @connection, @channel, @exchange = nil, nil, nil
    end

    def publish(routing_key, message, options={})
      json_message = JSON.dump(message)

      metadata = options.merge(
        routing_key: routing_key,
        timestamp: Time.now.to_i,
        message_id: generate_id
      )

      unless @connection
        raise Qsagi::PublishError
      end

      @exchange.publish(json_message, metadata)
    end

    def generate_id
      SecureRandom.uuid
    end
  end
end
