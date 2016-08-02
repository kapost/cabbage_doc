module CabbageDoc
  class Processor
    class InvalidProcessorError < StandardError; end

    class << self
      def inherited(klass)
        all[klass.to_s.split('::').last.downcase.to_sym] = klass
      end

      def all
        @_all ||= {}
      end

      def perform(type)
        klass = all[type]

        if klass
          klass.new.perform
        else
          raise InvalidProcessorError, type
        end
      end

      def load!
        Dir.glob(File.join(File.dirname(__FILE__), 'processors', '*.rb')).sort.each do |processor|
          require(processor)
        end
      end
    end

    def perform
      raise NotImplementedError
    end

    protected

    def client
      @_client ||= Client.new(auth)
    end

    def auth
      @_auth ||= Authentication.new
    end

    def collection
      @_collection ||= Collection.instance.tap do |collection|
        collection.load!
      end
    end
  end

  Processor.load!
end
