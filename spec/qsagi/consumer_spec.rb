require "spec_helper"

describe Qsagi::Consumer do
  let(:single_consumer) do
    unless defined? SingleConsumer
      class SingleConsumer
        include Qsagi::Consumer

        application "my_application"
        subscribe "qsagi.test"
      end
    end

    SingleConsumer
  end

  let(:multi_topic_consumer) do
    unless defined? MultiTopicConsumer
      class MultiTopicConsumer
        include Qsagi::Consumer

        subscribe "qsagi.test", "qsagi.test", "qsagi.test2"
      end
    end

    MultiTopicConsumer
  end

  describe ".included" do
    before { Object.send(:remove_const, :SingleConsumer) if defined?(SingleConsumer) }

    it "adds consumer to main process" do
      Qsagi.should_receive(:register_consumer) do |klass|
        klass.should == single_consumer
      end

      single_consumer
    end
  end

  describe ".subscribe" do
    context "with one topic" do
      subject { single_consumer }
      its(:topics) { should include("qsagi.test") }
    end

    context "with multiple topics" do
      subject { multi_topic_consumer }

      its(:topics) { should include("qsagi.test", "qsagi.test2") }

      it "ignores duplicates" do
        subject.topics.length.should == 2
      end
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
