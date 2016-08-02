module CabbageDoc
  class Configuration
    include Singleton

    DEFAULTS = {
      version: 'v1',
      path: 'api/v1',
      title: 'Cabbage Doc',
      scheme: 'https',
      verbose: false,
      dev: false,
      cache: Cache.new,
      request: proc { |request| request.perform }
    }.freeze

    OPTIONAL_ATTRIBUTES = %i(welcome path scheme version title verbose authentication dev request cache).freeze
    REQUIRED_ATTRIBUTES = %i(domain controllers root).freeze
    ATTRIBUTES          = (OPTIONAL_ATTRIBUTES + REQUIRED_ATTRIBUTES).freeze
    CALLABLE_ATTRIBUTES = %i(controllers authentication request).freeze

    attr_accessor *ATTRIBUTES 

    def initialize
      DEFAULTS.each do |attr, value|
        send(:"#{attr}=", value)
      end
    end

    def validate!
      validate_required!
      validate_callable!
      validate_root!
    end

    private

    def validate_required!
      REQUIRED_ATTRIBUTES.each do |attr|
        raise ArgumentError, "#{attr} is required" unless send(attr)
      end
    end

    def validate_callable!
      CALLABLE_ATTRIBUTES.each do |attr|
        if (value = send(attr)) && !value.respond_to?(:call)
          raise ArgumentError, "#{attr} is not callable"
        end
      end
    end

    def validate_root!
      raise ArgumentError, "#{root} directory doesn't exist" unless Dir.exists?(root)
    end
  end
end
