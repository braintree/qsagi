require "securerandom"

module Qsagi
  class PublishError < StandardError; end

  class Broker
    attr_reader :connection, :channel, :exchange

    def initialize(config = {})
      @config = Qsagi::Config.new(config)
    end

    def connect
      @connection = Bunny.new(@config.broker_options)

      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.exchange(@config.exchange_name, @config.exchange_options)
    end

    def disconnect
      @connection.close
      @connection, @channel, @exchange = nil, nil, nil
    end

    def ack(delivery_tag)
      @channel.ack(delivery_tag)
    end

    def nack(delivery_tag)
      @channel.nack(delivery_tag, requeue: false)
    end

    def publish(routing_key, message, options={})
      json_message = JSON.dump(message)

      metadata = options.merge(
        routing_key: routing_key,
        timestamp: Time.now.to_i,
        message_id: generate_id,
        content_type: "application/json"
      )

      if @connection.nil? || @connection.closed?
        raise Qsagi::PublishError
      end

      @exchange.publish(json_message, metadata)
    end

    def connected?
      @connection.open?
    end

    def wait_on_threads(timeout)
      @channel.work_pool.threads.none? do |thread|
        thread.join(timeout).nil?
      end
    end

    def stop
      @channel.work_pool.kill
    end

    def queue(name)
      @channel.queue(name, durable: true)
    end

    def bind_queue(queue, routing_keys)
      routing_keys.each do |routing_key|
        queue.bind(@exchange, routing_key: routing_key)
      end
    end

    def generate_id
      SecureRandom.uuid
    end
  end
end
