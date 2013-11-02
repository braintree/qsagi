module Qsagi
  class Worker
    def initialize(broker, consumers)
      @broker = broker
      @consumers = consumers
    end

    def run
      make_queues
    end

    def make_queues
      @consumers.each do |consumer|
        make_queue(consumer)
      end
    end

    def make_queue(consumer)
      queue = @broker.queue(consumer.queue_name)
      @broker.bind_queue(queue, consumer.topics)

      queue.subscribe(ack: true) do |delivery_info, properties, payload|
        body = JSON.load(payload, nil, symbolize_names: true)
        consumer.new.perform(body)
        @broker.ack(delivery_info.delivery_tag)
      end
    end
  end
end
