require 'httparty'

module CabbageDoc
  class Client
    include HTTParty

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
