module Qsagi
  class CLI
    attr_accessor :config

    def run
      if load_app && start == :success
        exit 0
      else
        exit 1
      end
    end

    def stop
      @worker.stop
    end

    def load_app
      path = "."
      if File.directory?(path)
        rails_path = File.expand_path(File.join(path, "config/environment.rb"))
        if File.exists?(rails_path)
          require rails_path
          ::Rails.application.eager_load!
        end
      end
      true
    end

    def start
      broker = Qsagi.connect(config)
      @worker = Qsagi::Worker.new(broker, Qsagi.consumers)
      @worker.run
      :success
    rescue => e
      :error
    end
  end
end
