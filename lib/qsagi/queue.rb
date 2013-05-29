module Qsagi
  module Queue
    def ack(message)
      @queue.ack(:delivery_tag => message.delivery_tag)
    end

    def clear
      loop do
        message = @queue.pop
        break if message[:payload] == :queue_empty
      end
    end

    def connect
      @client = Bunny.new(:host => self.class.host, :port => self.class.port, :heartbeat => self.class.heartbeat)
      @client.start
      @queue = @client.queue(self.class.queue_name, :durable => true, :arguments => {"x-ha-policy" => "all"})
      @exchange = @client.exchange(self.class._exchange)
      @queue.bind(@exchange, :key => self.class.queue_name) unless self.class._exchange.empty?
    end

    def disconnect
      @client.send(:close_socket) unless @client.nil?
    end

    def length
      @queue.status[:message_count]
    end

    def pop(options = {})
      auto_ack = options.fetch(:auto_ack, true)
      message = @queue.pop(:ack => !auto_ack)

      unless message[:payload] == :queue_empty
        self.class._message_class.new(message, self.class._serializer.deserialize(message[:payload]))
      end
    end

    def push(message)
      serialized_message = self.class._serializer.serialize(message)
      @exchange.publish(serialized_message, :key => @queue.name, :persistent => true, :mandatory => true)
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

      def exchange(exchange)
        @exchange = exchange
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

      def _message_class
        @message_class || Qsagi::Message
      end

      def _serializer
        @serializer || Qsagi::DefaultSerializer
      end
    end
  end
end
