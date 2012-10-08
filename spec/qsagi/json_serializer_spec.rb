require "spec_helper"

describe Qsagi::JsonSerializer do
  describe "self.deserialize" do
    it "parses json" do
      Qsagi::JsonSerializer.deserialize('{"a": "b"}').should == {"a" => "b"}
    end
  end

  describe "self.serialize" do
    it "parses json" do
      Qsagi::JsonSerializer.serialize({"a" => "b"}).should == '{"a":"b"}'
    end
  end

  it "serializes and deserializes correctly through a queue" do
    json_queue = Class.new(ExampleQueue) do
      serializer Qsagi::JsonSerializer
    end
    json_queue.connect do |queue|
      queue.push :a => 1
      queue.pop.payload.should == {'a' => 1}
    end
  end
end
