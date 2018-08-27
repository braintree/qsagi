module Qsagi
  module Queue
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def connect(opts={}, &block)
        options = default_options.merge(opts)
        queue = _queue(options)

        begin
          queue.connect

          block.call(queue)
        ensure
          queue.disconnect
        end
      end

      def _queue(options)
        standard_queue = StandardQueue.new(options)
        if options[:queue_type] == :confirmed
          ConfirmedQueue.new(standard_queue)
        else
          standard_queue
        end
      end

      def default_options
        {
          :host => host,
          :port => port,
          :queue_type => :standard,
          :heartbeat => heartbeat,
          :message_class => _message_class,
          :queue_name => queue_name,
          :durable => true,
          :queue_arguments => {"x-ha-policy" => "all"},
          :persistent => true,
          :mandatory => true,
          :serializer => _serializer,
          :exchange_options => _exchange_options,
          :exchange => _exchange,
          :connect_timeout => 5,
          :read_timeout => 5,
          :write_timeout => 5,
          :logger => nil
        }
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
