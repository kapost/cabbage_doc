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

      def tags(value = nil)
        if value.nil?
          @_tags
        else
          @_tags = !!value
        end
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

      def supports?(type, what)
        !!find(type).public_send(what)
      end

      def exists?(type)
        all.has_key?(type)
      end

      def perform(type, tag = nil)
        if type == :all
          all.map { |_, klass| klass.new(tag).perform }
        else
          find(type).new(tag).perform
        end
      end

      def find(type)
        klass = all[type]

        raise InvalidType, type unless klass

        klass
      end

      def load!
        Dir.glob(File.join(File.dirname(__FILE__), 'generators', '*.rb')).sort.each do |generator|
          require(generator)
        end
      end
    end

    attr_accessor :tag

    def initialize(tag = nil)
      self.tag = tag
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

    def controllers
      @_controllers ||= config.controllers.call
    end

    def config
      @_config ||= Configuration.instance
    end
  end

  Generator.load!
end
