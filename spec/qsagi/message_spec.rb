require "spec_helper"

describe Qsagi::Message do
  describe "delivery_tag" do
    it "returns the delivery_tag" do
      delivery_details = OpenStruct.new(:delivery_tag => "tag")
      expect(Qsagi::Message.new(delivery_details, :parsed_payload).delivery_tag).to eq "tag"
    end
  end

  describe "exchange" do
    it "returns the exchange" do
      delivery_details = OpenStruct.new(:exchange => "the_exchange")
      expect(Qsagi::Message.new(delivery_details, :parsed_payload).exchange).to eq "the_exchange"
    end
  end

  describe "payload" do
    it "returns the parsed payload" do
      expect(Qsagi::Message.new(:deliver_details, :parsed_payload).payload).to eq :parsed_payload
    end
  end
end
