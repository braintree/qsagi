require "bunny"
require "json"

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

  def self.consumers
    @consumers ||= []
  end
end
