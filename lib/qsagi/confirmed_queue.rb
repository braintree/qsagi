module Qsagi
  class ConfirmedQueue
    attr_reader :nacked_messages

    def initialize(queue)
      @queue = queue
      @nacked_messages = []
      @unconfirmed_messages = {}
      @wait_for_confirms = false
    end

    def connect
      @queue.connect
      _confirm_select
    end

    def disconnect
      @queue.disconnect
    end

    def push(message)
      @unconfirmed_messages[_channel.next_publish_seq_no] = message
      @queue.push(message)
      @wait_for_confirms = true
    end

    def pop(opts={})
      @queue.pop(opts)
    end

    def wait_for_confirms
      _channel.wait_for_confirms if _wait_for_confirms?
    end

    def _channel
      @queue.channel
    end

    def _confirm_messages!(attributes)
      if attributes[:is_nack]
        if attributes[:multiple]
          @nacked_messages += @unconfirmed_messages.select { |k,v| k <= attributes[:delivery_tag] }.values
          @unconfirmed_messages.delete_if { |k,v| k <= attributes[:delivery_tag] }
        else
          @nacked_messages << @unconfirmed_messages.delete(attributes[:delivery_tag])
        end
      else
        if attributes[:multiple]
          @unconfirmed_messages.delete_if { |k,v| k <= attributes[:delivery_tag] }
        else
          @unconfirmed_messages.delete(attributes[:delivery_tag])
        end
      end
    end

    def _confirm_select
      _channel.confirm_select lambda { |delivery_tag, multiple, is_nack|
        _confirm_messages!(:delivery_tag => delivery_tag, :multiple => multiple, :is_nack => is_nack)
      }
    end

    def _wait_for_confirms?
      @wait_for_confirms
    end
  end
end
