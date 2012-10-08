require "qsagi"

class ExampleQueue
  include Qsagi::Queue

  def self.host
    "127.0.0.1"
  end

  def self.port
    5672
  end

  def self.queue_name
    "qsagi_testing"
  end
end

RSpec.configure do |c|
  c.before(:each) do
    client = Bunny.new(:host => ExampleQueue.host, :port => ExampleQueue.port)
    client.start
    queue = client.queue(ExampleQueue.queue_name, :durable => true, :arguments => {"x-ha-policy" => "all"})
    queue.delete rescue nil
    client.send(:close_socket)
  end
end
