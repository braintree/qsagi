module Qsagi
  module Queue
    def ack(message)
      @channel.ack(message.delivery_tag, false)
    end

    def clear
      @queue.purge
    end

    def connect
      @client = Bunny.new(:host => self.class.host, :port => self.class.port, :heartbeat => self.class.heartbeat)
      @client.start
      @channel = @client.create_channel
      @exchange = @channel.exchange(self.class._exchange, self.class._exchange_options)
      @queue = @channel.queue(self.class.queue_name, :durable => true, :arguments => {"x-ha-policy" => "all"})
      @queue.bind(@exchange, :routing_key => self.class.queue_name) unless self.class._exchange.empty?
    end

    def disconnect
      @client.send(:close) unless @client.nil?
    end

    def length
      @queue.status[:message_count]
    end

    def pop(options = {})
      auto_ack = options.fetch(:auto_ack, true)
      delivery_info, properties, message = @queue.pop(:ack => !auto_ack)

      unless message.nil?
        self.class._message_class.new(delivery_info, self.class._serializer.deserialize(message))
      end
    end

    def push(message)
      serialized_message = self.class._serializer.serialize(message)
      @exchange.publish(serialized_message, :routing_key => @queue.name, :persistent => true, :mandatory => true)
    end

    def reconnect
      disconnect
      connect
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def connect(&block)
        queue = new

        begin
          queue.connect

          block.call(queue)
        ensure
          queue.disconnect
        end
      end

      def exchange(exchange, options = {})
        @exchange = exchange
        @exchange_options = {:type => :direct}.merge(options)
      end

      def message_class(message_class)
        @message_class = message_class
      end

      def serializer(serializer)
        @serializer = serializer
      end

      def _exchange
        @exchange || ""
      end

      def _exchange_options
        @exchange_options || {}
      end

      def _message_class
        @message_class || Qsagi::Message
      end

      def _serializer
        @serializer || Qsagi::DefaultSerializer
      end
    end
  end
end
