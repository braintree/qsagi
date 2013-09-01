module Qsagi
  class Message
    attr_reader :payload

    def initialize(delivery_details, payload)
      @delivery_details = delivery_details
      @payload = payload
    end

    def delivery_tag
      @delivery_details.delivery_tag
    end

    def exchange
      @delivery_details.exchange
    end
  end
end
