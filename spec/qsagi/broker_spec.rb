require "spec_helper"

describe Qsagi::Broker do
  describe "#connect" do
    it "connects with default config" do
      broker = Qsagi::Broker.new
      broker.connect
      broker.connection.should be_a Bunny::Session
      broker.channel.should be_a Bunny::Channel
      broker.exchange.should be_a Bunny::Exchange
    end

    it "raises error when config is invalid" do
      broker = Qsagi::Broker.new(host: "invalid")
      expect do
        broker.connect
      end.to raise_error
    end
  end

  describe "#disconnect" do
    it "disconnects and clears ivars" do
      broker = Qsagi::Broker.new
      broker.connect
      broker.disconnect

      broker.connection.should be_nil
      broker.channel.should be_nil
      broker.exchange.should be_nil
    end
  end
end
