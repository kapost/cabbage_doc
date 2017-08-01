module CabbageDoc
  class Configuration
    include Singleton

    class << self
      def format_example(example, action, auth)
        cmd = ["$", "curl"]

        if auth.type == :basic
          cmd << "-u \"user:pass\""
        elsif auth.token
          cmd << "-H \"Authorization: #{auth.type.to_s.capitalize} token\""
        end

        if action.method == "GET"
          path = [action.path, example.to_query].join("?")
        else
          cmd << "-X #{action.method}"

          example.params.each do |k, v|
            cmd << "-d \"#{k}=#{v}\""
          end

          path = action.path
        end

        cmd << "\"#{[auth.uri, path].join}\""

        cmd.join(' ')
      end
    end

    DEFAULTS =
    {
      path: 'api/v1',
      title: 'Cabbage Doc',
      scheme: 'https',
      verbose: false,
      dev: false,
      visibility: [VISIBILITY.first],
      cache: Cache.new,
      request: proc { |request| request.perform },
      authentication: proc { |auth, request| },
      theme: 'github',
      examples: false,
      format_example: method(:format_example),
      page_root: 'pages',
      page_ext: 'md',
      auto_generate: true,
      generators: [:api],
      tags: [TAG],
      json: false
    }.freeze

    OPTIONAL_ATTRIBUTES = %i(welcome path scheme title verbose authentication dev request cache
                              theme visibility examples format_example page_root page_ext
                              asset_path auto_generate generators tags json).freeze
    REQUIRED_ATTRIBUTES = %i(domain controllers root).freeze
    ATTRIBUTES          = (OPTIONAL_ATTRIBUTES + REQUIRED_ATTRIBUTES).freeze
    CALLABLE_ATTRIBUTES = %i(controllers authentication request format_example).freeze

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
      validate_visibility!
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

    def validate_visibility!
      self.visibility = Array(visibility)
      self.visibility.each do |v|
        valid = VISIBILITY.include?(v) || tags.include?(v)
        raise ArgumentError, "#{v} invalid visibility" unless valid
      end
    end
  end
end
