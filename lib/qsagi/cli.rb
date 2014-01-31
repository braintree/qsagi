require "optparse"

module Qsagi
  class CLI
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
      broker = Qsagi.connect(parse_options)
      @worker = Qsagi::Worker.new(broker, Qsagi.consumers)
      @worker.run
      :success
    rescue => e
      :error
    end

    def parse_options
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: qsagi [options]"

        opts.on("-H", "--host HOST", "RabbitMQ Host") do |value|
          options[:host] = value
        end

        opts.on("-P", "--port PORT", "RabbitMQ Port") do |value|
          options[:port] = value
        end

        opts.on("-V", "--vhost [VHOST]", "RabbitMQ Vhost") do |value|
          options[:vhost] = value
        end

        opts.on("-u", "--user USER", "RabbitMQ User") do |value|
          options[:user] = value
        end

        opts.on("-p", "--password PASSWORD", "RabbitMQ Password") do |value|
          options[:password] = value
        end

        opts.on("--heartbeat [HEARTBEAT]", "RabbitMQ Heartbeat") do |value|
          options[:heartbeat] = value
        end

        opts.on("--[no-]recovery", "Automatically Recover") do |value|
          options[:automatically_recover] = value
        end

        opts.on("--recovery-interval [INTERVAL]", "Try recovering every N seconds") do |value|
          options[:network_recovery_interval] = value
        end

        opts.on_tail("-h", "--help", "Help") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts Qsagi::VERSON
          exit
        end
      end.parse!(ARGV)

      options
    end
  end
end
