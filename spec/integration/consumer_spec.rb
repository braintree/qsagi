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
    let(:queue) { broker.queue(simple_consumer.queue_name) }

    before { cli.config = {exchange: "testing"} }
    before { broker.connect }
    before { queue.purge }

    after { broker.disconnect }

    it "performs work when a message is enqueued" do
      simple_consumer.any_instance.should_receive(:perform).with({}) do
        cli.stop
      end

      broker.publish("qsagi.integration.test", {})

      cli.run
    end

    xit "nacks the message when failing to process" do
      Qsagi::Broker.any_instance.should_receive(:nack) do
        cli.stop
      end

      simple_consumer.any_instance.should_receive(:perform).and_raise("boom!")

      broker.publish("qsagi.integration.test", {})

      cli.run

      expect(queue.message_count).to be_zero
    end
  end
end
