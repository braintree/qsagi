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
    before { cli.config = {exchange: "testing"} }

    it "performs work when a message is enqueued" do
      simple_consumer.any_instance.should_receive(:perform).with({})

      Qsagi.connect(exchange: "testing") do |broker|
        broker.publish("qsagi.integration.test", {})
      end

      cli.run
    end
  end
end
