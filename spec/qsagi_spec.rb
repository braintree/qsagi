require "spec_helper"

describe Qsagi do
  describe ".register_consumer" do
    it "stores consumers" do
      Qsagi.register_consumer(:consumer_1)
      Qsagi.register_consumer(:consumer_2)

      expect(Qsagi.consumers).to include(:consumer_1, :consumer_2)
    end
  end

  describe ".connect" do
    context "with block" do
      it "yields to a block with connected broker" do
        yielded = false

        Qsagi.connect do |broker|
          expect(broker).to be_connected
          yielded = true
        end

        expect(yielded).to be_true
      end

      it "disconnects" do
        Qsagi::Broker.any_instance.should_receive(:disconnect)

        Qsagi.connect { }
      end
    end

    context "without block" do
      it "returns a connected broker" do
        expect(Qsagi.connect).to be_connected
      end
    end
  end
end
