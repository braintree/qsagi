module Qsagi
  class Worker
    def initialize(broker, consumers)
      @broker = broker
      @consumers = consumers
    end

    def run
      @consumers.each do |consumer|
        subscribe!(consumer)
      end

      register_signal_handlers

      handle_signals until @broker.wait_on_threads(0.1)
    end

    def subscribe!(consumer)
      queue = @broker.queue(consumer.queue_name)
      @broker.bind_queue(queue, consumer.topics, consumer.exchange)

      queue.subscribe(ack: true) do |delivery_info, properties, payload|
        handle_message(consumer, delivery_info, properties, payload)
      end
    end

    def handle_message(consumer, delivery_info, properties, payload)
      body = JSON.load(payload, nil, symbolize_names: true)
      consumer.new.perform(body)
      @broker.ack(delivery_info.delivery_tag)
    rescue => e
      @broker.nack(delivery_info.delivery_tag)
    end

    def register_signal_handlers
      Thread.main[:signals] = []
      [:QUIT, :TERM, :INT].each do |signal|
        trap(signal) do
          Thread.main[:signals] << signal
        end
      end
    end

    def handle_signals
      signal = Thread.main[:signals].shift
      if signal
        stop
      end
    end

    def stop
      @broker.stop
    end
  end
end
