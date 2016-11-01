module CabbageDoc
  class Authentication
    class << self
      def new(request = nil)
        super().tap do |auth|
          yield(auth) if block_given?
          Configuration.instance.authentication.call(auth, request)
        end
      end
    end

    attr_accessor :type,
                  :username,
                  :password,
                  :token,
                  :domain,
                  :subdomain,
                  :subdomains,
                  :scheme,
                  :path,
                  :user_agent,
                  :configurable,
                  :verbose,
                  :visibility

    def initialize
      Configuration.instance.tap do |config|
        @domain     = config.domain
        @scheme     = config.scheme
        @path       = config.path
        @user_agent = config.title
        @verbose    = config.verbose
        @visibility = config.visibility.dup
      end

      @subdomains = []
      @configurable = []
      @type = :basic
    end

    def visibility=(value)
      @visibility = Array(value)
    end

    def uri
      if path && path != '/'
        "#{root_uri}/#{path}"
      else
        root_uri
      end
    end

    def valid?
      case type
      when :basic
        username && password
      else
        !token.nil?
      end
    end

    def configurable?
      @configurable.any?
    end

    private

    def root_uri
      if subdomain
        "#{scheme}://#{subdomain}.#{domain}"
      else
        "#{scheme}://#{domain}"
      end
    end
  end
end
