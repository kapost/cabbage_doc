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
                  :live,
                  :configurable,
                  :verbose,
                  :headless

    def initialize
      Configuration.instance.tap do |config|
        @domain     = config.domain
        @scheme     = config.scheme
        @path       = config.path
        @user_agent = config.title
      end

      @verbose = false
      @subdomains = []
      @live = true
      @headless = false
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

    def headless?
      @headless == true
    end

    def configurable?
      @configurable.any? || @subdomains.any?
    end
  end
end
