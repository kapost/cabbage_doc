module CabbageDoc
  class Generator
    class Error < StandardError; end
    class InvalidType < Error; end
    class InvalidPriority < Error; end

    PRIORITIES = [:high, :medium, :low].freeze

    class << self
      def inherited(klass)
        all[klass.to_s.split('::').last.downcase.to_sym] = klass
      end

      def priority(value = nil)
        if value.is_a?(Symbol)
          raise InvalidPriority, value unless PRIORITIES.include?(value)
          @_priority = value
        else
          @_priority
        end
      end

      def all
        @_all ||= {}
      end

      def perform(type)
        klass = all[type]

        if klass
          klass.new.perform
        else
          raise InvalidType, type
        end
      end

      def load!
        Dir.glob(File.join(File.dirname(__FILE__), 'generators', '*.rb')).sort.each do |generator|
          require(generator)
        end
      end
    end

    def perform
      raise NotImplementedError
    end

    protected

    def cache
      @_cache ||= Cache.new
    end

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

    def config
      @_config ||= Configuration.instance
    end
  end

  Generator.load!
end
