require "spec_helper"

describe Qsagi do
  describe ".register_consumer" do
    it "stores consumers" do
      Qsagi.register_consumer(:consumer_1)
      Qsagi.register_consumer(:consumer_2)

      expect(Qsagi.consumers).to include(:consumer_1, :consumer_2)
    end
  end
end
