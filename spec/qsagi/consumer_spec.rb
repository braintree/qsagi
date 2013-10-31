require "spec_helper"

describe Qsagi::Consumer do
  let(:single_consumer) do
    class SingleConsumer
      include Qsagi::Consumer

      application "my_application"
      subscribe "qsagi.test"
    end

    SingleConsumer
  end

  let(:multi_topic_consumer) do
    class MultiTopicConsumer
      include Qsagi::Consumer

      subscribe "qsagi.test", "qsagi.test", "qsagi.test2"
    end

    MultiTopicConsumer
  end

  describe ".subscribe" do
    it "stores topics subscribed" do
      single_consumer.topics.should include("qsagi.test")
    end

    it "only stores unique values" do
      multi_topic_consumer.topics.length.should == 2
      multi_topic_consumer.topics.should include("qsagi.test", "qsagi.test2")
    end
  end

  describe ".queue_name" do
    it "namespaces queue with application name" do
      single_consumer.queue_name.should == "my_application.single_consumer"
    end

    it "does not start with period if application not set" do
      multi_topic_consumer.queue_name.should == "multi_topic_consumer"
    end
  end
end
