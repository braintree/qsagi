require "spec_helper"

describe "simple consumer", :integration => true do
  context "with topics" do
    let(:simple_consumer) do
      unless defined? SimpleConsumer
        class SimpleConsumer
          include Qsagi::Consumer
          subscribe "qsagi.integration.test"
          exchange_name "testing"
        end
      end

      SimpleConsumer
    end

    subject(:cli) { Qsagi::CLI.new }
    let(:broker) { Qsagi::Broker.new(application_name: "qsagi", exchange: {name: "testing", type: :topic}) }
    let(:queue) { broker.queue(simple_consumer.queue_name) }
    let(:dead_letter_queue) { broker.queue(simple_consumer.queue_name, "dlq").bind("dlx.qsagi", :routing_key => "qsagi.integration.test") }

    before { broker.connect }
    before { queue.purge }
    before { dead_letter_queue.purge }
    before { cli.stub(:parse_options).and_return(application_name: "qsagi") }

    after { broker.disconnect }

    it "performs work when a message is enqueued" do
      simple_consumer.any_instance.should_receive(:perform).with({})

      broker.publish("qsagi.integration.test", {})

      expect do
        Timeout::timeout(1.0, SystemExit) { cli.run }
      end.to raise_error(SystemExit)

      expect(queue.message_count).to be_zero
    end

    it "nacks the message when failing to process" do
      simple_consumer.any_instance.should_receive(:perform).and_raise("boom!")

      broker.publish_and_wait("qsagi.integration.test", {})

      expect do
        Timeout::timeout(1.0, SystemExit) { cli.run }
      end.to raise_error(SystemExit)

      expect(queue.message_count).to be_zero
      expect(dead_letter_queue.message_count).to eql(1)
    end
  end
end
