require "spec_helper"

describe Qsagi::Queue do
  it "and push and pop from a queue" do
    ExampleQueue.connect do |queue|
      queue.push("message")
      result = queue.pop
      expect(result.payload).to eq("message")
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
        expect(message.payload).to eq("message1")
        expect(message.exchange).to eq("exchange1")
      end
      queue_on_exchange2.connect do |queue|
        expect(queue.pop).to be_nil
      end
    end
  end

  describe "clear" do
    it "clears the queue" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        queue.clear
        expect(queue.pop).to be_nil
      end
    end
  end

  describe "length" do
    it "returns the number of messages in the queue" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        expect(queue.length).to eq(1)
        queue.push("message")
        expect(queue.length).to eq(2)
        queue.pop
        expect(queue.length).to eq(1)
      end
    end
  end

  describe "reject" do
    it "rejects the message and places it back on the queue" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        message = queue.pop(:auto_ack => false)
        queue.reject(message, :requeue => true)
      end
      ExampleQueue.connect do |queue|
        expect(queue.length).to eq(1)
      end
    end

    it "rejects and discards the message" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        message = queue.pop(:auto_ack => false)
        queue.reject(message, :requeue => false)
      end
      ExampleQueue.connect do |queue|
        expect(queue.length).to eq(0)
      end
    end
  end

  describe "pop" do
    it "automatically acks if :auto_ack is not passed in" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        message = queue.pop
        expect(message.payload).to eq("message")
      end
      ExampleQueue.connect do |queue|
        message = queue.pop
        expect(message).to be_nil
      end
    end

    it "will not automatically ack if :auto_ack is set to false" do
      ExampleQueue.connect do |queue|
        queue.push("message")
        message = queue.pop(:auto_ack => false)
        expect(message.payload).to eq("message")
      end
      ExampleQueue.connect do |queue|
        message = queue.pop(:auto_ack => false)
        expect(message.payload).to eq("message")
        queue.ack(message)
      end
      ExampleQueue.connect do |queue|
        message = queue.pop(:auto_ack => false)
        expect(message).to be_nil
      end
    end
  end

  describe "queue_type confirmed" do
    it "should use a ConfirmedQueue" do
      ExampleQueue.connect(:queue_type => :confirmed) do |queue|
        queue.push("message")
        queue.wait_for_confirms
        expect(queue.nacked_messages.size).to eq(0)
      end
    end
  end
end
