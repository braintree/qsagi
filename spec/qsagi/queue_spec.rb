require "spec_helper"

describe Qsagi::Queue do
  it "and push and pop from a queue" do
    ExampleQueue.connect do |queue|
      queue.push("message")
      result = queue.pop
      result.payload.should == "message"
    end
  end

  describe "self.exchange" do
    it "configures the exchange" do
      queue_on_exchange1 = Class.new(ExampleQueue) do
        exchange "exchange1", :type => :direct
      end
      queue_on_exchange2 = Class.new(ExampleQueue) do
        exchange "exchange2"
      end
      queue_on_exchange1.connect do |queue|
        queue.push "message1"
      end
      queue_on_exchange1.connect do |queue|
        message = queue.pop
        message.payload.should == "message1"
        message.exchange.should == "exchange1"
      end
      queue_on_exchange2.connect do |queue|
        queue.pop.should be_nil
      end
    end
  end

  describe "clear" do
    it "clears the queue" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        queue.clear
        queue.pop.should == nil
      end
    end
  end

  describe "length" do
    it "returns the number of messages in the queue" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        queue.length.should == 1
        queue.push("message")
        queue.length.should == 2
        queue.pop
        queue.length.should == 1
      end
    end
  end

  describe "pop" do
    it "automatically acks if :auto_ack is not passed in" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        message = queue.pop
        message.payload.should == "message"
      end
      ExampleQueue.connect do |queue|
        message = queue.pop
        message.should == nil
      end
    end

    it "will not automatically ack if :auto_ack is set to false" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        message = queue.pop(:auto_ack => false)
        message.payload.should == "message"
      end
      ExampleQueue.connect do |queue|
        message = queue.pop(:auto_ack => false)
        message.payload.should == "message"
        queue.ack(message)
      end
      ExampleQueue.connect do |queue|
        message = queue.pop(:auto_ack => false)
        message.should == nil
      end
    end
  end
end
