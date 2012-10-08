require "spec_helper"

describe Qsagi::Message do
  describe "delivery_tag" do
    it "returns the delivery_tag" do
      data = {
        :delivery_details => {:delivery_tag => "tag"},
        :payload => "raw_payload"
      }
      Qsagi::Message.new(data, :parsed_payload).delivery_tag.should == "tag"
    end
  end

  describe "exchange" do
    it "returns the exchange" do
      data = {
        :delivery_details => {:exchange => "the_exchange"},
        :payload => "raw_payload"
      }
      Qsagi::Message.new(data, :parsed_payload).exchange.should == "the_exchange"
    end
  end

  describe "payload" do
    it "returns the parsed payload" do
      data = {
        :delivery_details => {:delivery_tag => "tag"},
        :payload => "raw_payload"
      }
      Qsagi::Message.new(data, :parsed_payload).payload.should == :parsed_payload
    end
  end
end
