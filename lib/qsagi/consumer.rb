module Qsagi
  module Consumer
    def self.included(klass)
      klass.extend(ClassMethods)
      Qsagi.register_consumer(klass)
    end

    module ClassMethods
      def exchange_name(name)
        @exchange_name = name
      end

      def exchange_type(type)
        @exchange_type = type
      end

      def exchange
        {
          name: @exchange_name || "",
          options: {
            type: @exchange_type || :topic,
            durable: true,
            auto_delete: false
          }
        }
      end

      def dead_letter_exchange
        {
          name: @exchange_name.empty? ? "" : "dlx.#{@exchange_name}",
          options: {
            type: @exchange_type || :topic,
            durable: true,
            auto_delete: false
          }
        }
      end

      def queue_name
        _underscored_name.downcase
      end

      def subscribe(*topics)
        @topics = self.topics.union(topics)
      end

      def topics
        @topics ||= Set.new
      end

      def _underscored_name
        self.name.gsub(/::/, "_").gsub(/([^A-Z_])([A-Z])/) { "#{$1}_#{$2}" }
      end
    end
  end
end
