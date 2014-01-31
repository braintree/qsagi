require "bunny"
require "json"

require_relative "qsagi/worker"
require_relative "qsagi/cli"
require_relative "qsagi/config"
require_relative "qsagi/broker"
require_relative "qsagi/consumer"
require_relative "qsagi/message"
require_relative "qsagi/default_serializer"
require_relative "qsagi/json_serializer"
require_relative "qsagi/queue"
require_relative "qsagi/standard_queue"
require_relative "qsagi/confirmed_queue"
require_relative "qsagi/version"

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
