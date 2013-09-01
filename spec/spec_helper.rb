require "qsagi"
require "ostruct"

class ExampleQueue
  include Qsagi::Queue

  def self.host
    "127.0.0.1"
  end

  def self.port
    5672
  end

  def self.heartbeat
    300
  end

  def self.queue_name
    "qsagi_testing"
  end
end

RSpec.configure do |c|
  c.before(:each) do
    ExampleQueue.connect do |queue|
      queue.clear
    end
  end
end
