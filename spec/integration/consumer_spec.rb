require "spec_helper"

describe "simple consumer", :integration => true do
  context "with topics" do
    let(:simple_consumer) do
      unless defined? SimpleConsumer
        class SimpleConsumer
          include Qsagi::Consumer
          subscribe "qsagi.integration.test"
        end
      end

      SimpleConsumer
    end

    subject(:cli) { Qsagi::CLI.new }
    let(:broker) { Qsagi::Broker.new(exchange: "testing") }

    before { cli.config = {exchange: "testing"} }
    before { broker.connect }
    after { broker.disconnect }

    it "performs work when a message is enqueued" do
      simple_consumer.any_instance.should_receive(:perform).with({})

      broker.publish("qsagi.integration.test", {})

      cli.run
    end

    it "nacks the message when failing to process" do
      simple_consumer.any_instance.should_receive(:perform).and_raise("boom!")

      broker.publish("qsagi.integration.test", {})

      cli.run

      queue = broker.queue(simple_consumer.queue_name)
      broker.bind_queue(queue, simple_consumer.topics)

      expect(queue.message_count).to be_zero
    end
  end
end
