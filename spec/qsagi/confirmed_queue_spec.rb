require "spec_helper"

describe Qsagi::ConfirmedQueue do
  describe "_confirm_messages!" do
    it "adds a single nacked message to nacked_messages" do
      queue = Qsagi::ConfirmedQueue.new(nil)
      queue.instance_variable_set(:@unconfirmed_messages, {2 => "message"})
      queue._confirm_messages!(:delivery_tag => 2, :multiple => false, :is_nack => true)
      expect(queue.nacked_messages).to eq(["message"])
    end

    it "adds multiple nacked messages to nacked_messages" do
      queue = Qsagi::ConfirmedQueue.new(nil)
      queue.instance_variable_set(:@unconfirmed_messages, {2 => "message", 3 => "other_message"})
      queue._confirm_messages!(:delivery_tag => 3, :multiple => true, :is_nack => true)
      expect(queue.nacked_messages).to eq(["message", "other_message"])
    end

    it "removes a single acked message from unconfirmed_messages" do
      queue = Qsagi::ConfirmedQueue.new(nil)
      queue.instance_variable_set(:@unconfirmed_messages, {2 => "message", 3 => "other_message"})
      queue._confirm_messages!(:delivery_tag => 2, :multiple => false, :is_nack => false)
      expect(queue.instance_variable_get(:@unconfirmed_messages)).to eq(3 => "other_message")
    end

    it "removes multiple acked messages from unconfirmed_messages" do
      queue = Qsagi::ConfirmedQueue.new(nil)
      queue.instance_variable_set(:@unconfirmed_messages, {2 => "message", 3 => "other_message", 4 => "this_dude"})
      queue._confirm_messages!(:delivery_tag => 3, :multiple => true, :is_nack => false)
      expect(queue.instance_variable_get(:@unconfirmed_messages)).to eq(4 => "this_dude")
    end
  end
end
