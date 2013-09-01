require "spec_helper"

describe Qsagi::Message do
  describe "delivery_tag" do
    it "returns the delivery_tag" do
      delivery_details = OpenStruct.new(:delivery_tag => "tag")
      Qsagi::Message.new(delivery_details, :parsed_payload).delivery_tag.should == "tag"
    end
  end

  describe "exchange" do
    it "returns the exchange" do
      delivery_details = OpenStruct.new(:exchange => "the_exchange")
      Qsagi::Message.new(delivery_details, :parsed_payload).exchange.should == "the_exchange"
    end
  end

  describe "payload" do
    it "returns the parsed payload" do
      Qsagi::Message.new(:deliver_details, :parsed_payload).payload.should == :parsed_payload
    end
  end
end
