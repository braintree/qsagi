require "spec_helper"

describe Qsagi::Worker do
  let(:consumer) { double("Consumer", queue_name: "consumer1", topics: %w(test fire)) }
  let(:consumers) { [consumer, double("Consumer")] }
  let(:broker) { Qsagi::Broker.new }
  subject(:worker) { Qsagi::Worker.new(broker, consumers) }
  before { broker.stub(:wait_on_threads).and_return(true) }

  describe "#run" do
    it "makes a queue for each consumer" do
      consumers.each do |c|
        worker.should_receive(:subscribe!).with(c)
      end

      worker.run
    end
  end

  describe "#subscribe!" do
    let(:queue) { double("Queue", bind: nil, subscribe: nil) }
    before { broker.stub(queue: queue) }

    it "creates a queue" do
      broker.should_receive(:queue).with(consumer.queue_name).and_return(queue)
      worker.subscribe!(consumer)
    end

    it "binds to exchange with routing keys" do
      broker.should_receive(:bind_queue).with(queue, consumer.topics)
      worker.subscribe!(consumer)
    end

    it "subscribes to new messages" do
      queue.should_receive(:subscribe).with(ack: true)
      worker.subscribe!(consumer)
    end
  end

  describe "#handle_message" do
    let(:consumer_instance) { double("Consumer Instance") }
    let(:consumer) { double("Consumer", new: consumer_instance) }
    let(:delivery_info) { double("DeliveryInfo", delivery_tag: 1) }
    let(:properties) { double("Properties", message_id: nil) }
    let(:payload) { JSON.dump({}) }

    before { broker.stub(:ack) }

    it "calls perform on a consumer" do
      consumer_instance.should_receive(:perform).with({})
      worker.handle_message(consumer, delivery_info, properties, payload)
    end

    it "acks the message" do
      consumer_instance.should_receive(:perform).with({})
      broker.should_receive(:ack).with(1)
      worker.handle_message(consumer, delivery_info, properties, payload)
    end

    it "nacks the mesage when an error occurs" do
      consumer_instance.should_receive(:perform).and_raise("boom!")
      broker.should_receive(:nack).with(1)
      worker.handle_message(consumer, delivery_info, properties, payload)
    end
  end
end
