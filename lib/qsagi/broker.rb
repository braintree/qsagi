require "securerandom"

module Qsagi
  class PublishError < StandardError; end

  class Broker
    attr_reader :connection, :channel, :exchange

    def initialize(config = {})
      @config = Qsagi::Config.new(config)
      @published_messages = {}
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

    def publish_and_wait(routing_key, message, options={})
      enter_confirm_select!
      store_message_for_confirm(message)
      publish(routing_key, message, options)
      nacked_messages
    end

    def connected?
      @connection.open?
    end

    def wait_on_threads(timeout)
      return true unless @channel.work_pool.running?

      @channel.work_pool.threads.none? do |thread|
        thread.join(timeout).nil?
      end
    end

    def stop
      @channel.work_pool.kill if @channel.work_pool.running?
    end

    def queue(name, prefix="")
      @channel.queue(queue_prefix(prefix) + name, durable: true, arguments: queue_arguments)
    end

    def store_message_for_confirm(message)
      @published_messages[@channel.next_publish_seq_no] = message
    end

    def nacked_messages
      if wait_for_confirms
        @published_messages.clear
        []
      else
        @published_messages.values_at(*@channel.nacked_set)
      end
    end

    def bind_queue(queue, routing_keys, exchange)
      exchange = @channel.exchange(exchange[:name], exchange[:options])

      routing_keys.each do |routing_key|
        queue.bind(exchange, routing_key: routing_key)
      end
    end

    def generate_id
      SecureRandom.uuid
    end

    def enter_confirm_select!
      @channel.confirm_select unless @channel.using_publisher_confirmations?
    end

    def wait_for_confirms
      @channel.wait_for_confirms
    end

    def queue_prefix(prefix)
      application_prefix = @config.application_name + "."
      if prefix.empty?
        application_prefix
      else
        prefix + "." + application_prefix
      end
    end

    def queue_arguments
      {
        "x-ha-policy" => "all",
        "x-dead-letter-exchange" => "dlx.#{@config.application_name}"
      }
    end
  end
end
