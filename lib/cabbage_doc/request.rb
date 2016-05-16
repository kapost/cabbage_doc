module CabbageDoc
  class Request
    METHODS = %i[get post put delete].freeze

    attr_reader :raw_request, :collection

    def initialize(raw_request, collection)
      @raw_request = raw_request
      @collection = collection
    end

    def perform
      Response.new(url, params, perform_request) if valid?
    end

    def valid?
      action && method && METHODS.include?(method)
    end

    private

    def perform_request
      key = (method == :get) ? :query : :body
      client.send(method, action, key => params.to_hash)
    end

    def url
      @_url ||= [client.base_uri, action]
    end

    def action
      @_action ||= compose_action(raw_request.params['action'])
    end

    def method
      @_method ||= compose_method(raw_request.params['method'])
    end

    def compose_method(method)
      method.downcase.to_sym if method
    end

    def compose_action(action)
      return action unless action && action.include?(':')

      action = action.dup

      action.dup.scan(/\/:([^\/]+)/) do
        value = params.delete($1)
        return unless value

        action.sub!(":#{$1}", value)
      end

      action
    end

    def params
      @_params ||= Params.new(raw_request.params, collection)
    end

    def auth
      @_auth ||= Authentication.new(raw_request)
    end

    def client
      @_client ||= Client.new(auth)
    end
  end
end
