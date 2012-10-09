module Qsagi
  class Message
    attr_reader :payload

    def initialize(message, payload)
      @message = message
      @payload = payload
    end

    def delivery_tag
      _delivery_details[:delivery_tag]
    end

    def exchange
      _delivery_details[:exchange]
    end

    def _delivery_details
      @delivery_details ||= @message.fetch(:delivery_details, {})
    end
  end
end
