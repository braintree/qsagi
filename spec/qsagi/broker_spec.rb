require "spec_helper"

describe Qsagi::Broker do
  describe "#connect" do
    it "connects with default config" do
      config = {
        vhost: "/",
        host: "127.0.0.1",
        port: "5672",
        user: "guest",
        password: "guest",
        heartbeat: :server,
        exchange: "",
        exchange_type: :topic,
        logger: Logger.new($stdout)
      }

      broker = Qsagi::Broker.new(config)
      broker.connect
      broker.connection.should be_a Bunny::Session
      broker.channel.should be_a Bunny::Channel
      broker.exchange.should be_a Bunny::Exchange
    end

    it "raises error when config is invalid" do
      config = {
        vhost: "/",
        host: "invalid",
        port: "5672",
        user: "guest",
        password: "guest",
        heartbeat: :server,
        exchange: "",
        exchange_type: :topic,
        logger: Logger.new($stdout)
      }

      broker = Qsagi::Broker.new(config)
      expect do
        broker.connect
      end.to raise_error
    end
  end

  describe "#disconnect" do
    it "disconnects and clears ivars" do
      config = {
        vhost: "/",
        host: "127.0.0.1",
        port: "5672",
        user: "guest",
        password: "guest",
        heartbeat: :server,
        exchange: "",
        exchange_type: :topic,
        logger: Logger.new($stdout)
      }

      broker = Qsagi::Broker.new(config)
      broker.connect
      broker.disconnect

      broker.connection.should be_nil
      broker.channel.should be_nil
      broker.exchange.should be_nil
    end
  end
end
