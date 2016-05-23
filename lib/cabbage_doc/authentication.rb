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
                  :verbose

    def initialize
      Configuration.instance.tap do |config|
        @domain     = config.domain
        @scheme     = config.scheme
        @path       = config.path
        @user_agent = config.title
      end

      @verbose = false
      @subdomains = []
      @configurable = []
      @type = :basic
    end

    def valid?
      case type
      when :basic
        username && password
      when :token
        !token.nil?
      else
        false
      end
    end

    def configurable?
      @configurable.any?
    end
  end
end
