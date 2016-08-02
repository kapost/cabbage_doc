require 'yaml'
require 'digest/sha1'

module CabbageDoc
  class Request
    METHODS = %i[get post put delete].freeze

    attr_reader :raw_request, :collection

    class << self
      def parse(s)
        variables = YAML.load(s)

        new(nil, Collection.instance).tap do |instance|
          [:@_id, :@_auth, :@_action, :@_method, :@_params].each_with_index do |k, i|
            instance.instance_variable_set(k, variables[i])
          end
        end
      end
    end

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

    def to_yaml
      YAML.dump([
        id,
        auth,
        action,
        method,
        params
      ])
    end

    def id
      @_id ||= new_id
    end

    private

    def new_id
      components = [MARKER, Time.now.utc, Process.pid, Thread.current.object_id, rand(99999)]
      Digest::SHA1.hexdigest(components.join('_'))
    end

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
      @_params ||= Params.new(raw_params, collection)
    end

    def auth
      @_auth ||= Authentication.new(raw_request)
    end

    def raw_params
      @_raw_params ||= raw_request.params
    end

    def client
      @_client ||= Client.new(auth)
    end
  end
end
