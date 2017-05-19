require 'httparty'

module CabbageDoc
  class Client
    include HTTParty

    class CustomParser < HTTParty::Parser
      def json
        JSON.parse(body, :quirks_mode => true, :allow_nan => true)
      end
    end
    parser CustomParser

    class << self
      def new(auth)
        Class.new(self) do |klass|
          klass.headers "User-Agent" => auth.user_agent
          klass.base_uri auth.uri

          if auth.type == :basic
            klass.basic_auth auth.username, auth.password
          elsif auth.token
            klass.headers "Authorization" => "#{auth.type.to_s.capitalize} #{auth.token}"
          end

          debug_output $stdout if auth.verbose
        end
      end
    end
  end
end
