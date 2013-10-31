module Qsagi
  module Consumer
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def application(name)
        @application = name
      end

      def queue_name
        (_queue_prefix + _underscored_name).downcase
      end

      def subscribe(*topics)
        @topics = self.topics.union(topics)
      end

      def topics
        @topics ||= Set.new
      end

      def _queue_prefix
        @application.nil? ? "" : "#{@application}."
      end

      def _underscored_name
        self.name.gsub(/::/, "_").gsub(/([^A-Z_])([A-Z])/) { "#{$1}_#{$2}" }
      end
    end
  end
end
