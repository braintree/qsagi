require "bunny"
require "json"

require "qsagi/worker"
require "qsagi/cli"
require "qsagi/config"
require "qsagi/broker"
require "qsagi/consumer"
require "qsagi/message"
require "qsagi/default_serializer"
require "qsagi/json_serializer"
require "qsagi/queue"
require "qsagi/standard_queue"
require "qsagi/confirmed_queue"
require "qsagi/version"

module Qsagi
  def self.register_consumer(consumer)
    self.consumers << consumer
  end

  def self.connect(config = {})
    broker = Qsagi::Broker.new(config)
    broker.connect

    if block_given?
      begin
        yield broker
      ensure
        broker.disconnect
      end
    else
      broker
    end
  end

  def self.clear_consumers
    @consumers = nil
  end

  def self.consumers
    @consumers ||= []
  end
end
