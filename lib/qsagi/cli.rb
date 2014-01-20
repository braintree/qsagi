module Qsagi
  class CLI
    attr_accessor :config

    def run
      broker = Qsagi.connect(config)
      @worker = Qsagi::Worker.new(broker, Qsagi.consumers)
      @worker.run
    end

    def stop
      @worker.stop
    end
  end
end
