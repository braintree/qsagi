require "spec_helper"

describe Qsagi::JsonSerializer do
  describe "self.deserialize" do
    it "parses json" do
      expect(Qsagi::JsonSerializer.deserialize('{"a": "b"}')).to eq("a" => "b")
    end
  end

  describe "self.serialize" do
    it "parses json" do
      expect(Qsagi::JsonSerializer.serialize({"a" => "b"})).to eq('{"a":"b"}')
    end
  end

  it "serializes and deserializes correctly through a queue" do
    json_queue = Class.new(ExampleQueue) do
      serializer Qsagi::JsonSerializer
    end
    json_queue.connect do |queue|
      queue.push :a => 1
      expect(queue.pop.payload).to eq('a' => 1)
    end
  end
end
