module Qsagi
  class StandardQueue
    attr_reader :channel, :options

    def initialize(options={})
      @options = options
    end

    def ack(message)
      @channel.ack(message.delivery_tag, false)
    end

    def reject(message, options={})
      @channel.reject(message.delivery_tag, options.fetch(:requeue, true))
    end

    def clear
      @queue.purge
    end

    def connect
      @client = Bunny.new(
        :host => options[:host],
        :port => options[:port],
        :heartbeat => options[:heartbeat],
        :continuation_timeout => options[:continuation_timeout],
        :username => options[:username],
        :password => options[:password],
      )
      @client.start
      @channel = @client.create_channel
      @exchange = @channel.exchange(options[:exchange], options[:exchange_options])
      @queue = @channel.queue(options[:queue_name], :durable => options[:durable], :arguments => options[:queue_arguments])
      @queue.bind(@exchange, :routing_key => options[:queue_name]) unless options[:exchange].empty?
    end

    def disconnect
      @client.close unless @client.nil?
    end

    def length
      @queue.status[:message_count]
    end

    def pop(options = {})
      auto_ack = options.fetch(:auto_ack, true)
      delivery_info, properties, message = @queue.pop(:ack => !auto_ack)

      unless message.nil?
        _message_class.new(delivery_info, _serializer.deserialize(message))
      end
    end

    def push(message)
      serialized_message = options[:serializer].serialize(message)
      @exchange.publish(serialized_message, :routing_key => @queue.name, :persistent => options[:persistent], :mandatory => options[:mandatory])
    end

    def reconnect
      disconnect
      connect
    end

    def _message_class
      options[:message_class]
    end

    def _serializer
      options[:serializer]
    end
  end
end
