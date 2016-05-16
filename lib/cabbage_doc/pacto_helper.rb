module CabbageDoc
  module PactoHelper
    def pacto_enable!
      WebMock.allow_net_connect!

      Pacto.configure do |config|
        config.contracts_path = Configuration.instance.root
      end

      Pacto.generate!
    end

    def pacto_disable!
      Pacto.stop_generating!
    end

    def pacto_available?
      require 'forwardable'
      require 'pacto'

      defined?(Pacto)
    rescue LoadError => e
      puts "WARNING: Pacto is not available."
      false
    end
  end
end
