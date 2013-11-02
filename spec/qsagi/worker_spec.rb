require "spec_helper"

describe Qsagi::Worker do
  let(:consumer) { double("Consumer", queue_name: "consumer1", topics: %w(test fire)) }
  let(:consumers) { [consumer, double("Consumer")] }
  let(:broker) { Qsagi::Broker.new }
  subject(:worker) { Qsagi::Worker.new(broker, consumers) }

  describe "#make_queues" do
    it "makes a queue for each consumer" do
      consumers.each do |c|
        worker.should_receive(:make_queue).with(c)
      end

      worker.make_queues
    end
  end

  describe "#make_queue" do
    let(:queue) { double("Queue", bind: nil, subscribe: nil) }
    before { broker.stub(queue: queue) }

    it "creates a queue" do
      broker.should_receive(:queue).with(consumer.queue_name).and_return(queue)
      worker.make_queue(consumer)
    end

    it "binds to exchange with routing keys" do
      broker.should_receive(:bind_queue).with(queue, consumer.topics)
      worker.make_queue(consumer)
    end

    it "subscribes to new messages" do
      queue.should_receive(:subscribe).with(ack: true)
      worker.make_queue(consumer)
    end
  end
end
