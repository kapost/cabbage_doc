require 'yaml'
require 'ostruct'
require 'digest/sha1'

module CabbageDoc
  class Request
    METHODS = %i[get post put delete].freeze

    attr_reader :raw_request, :collection

    class << self
      def parse(s, tag = TAG)
        variables = YAML.load(s)

        new(OpenStruct.new(params: {}, env: {}), Collection.instance).tap do |instance|
          [:@_id, :@_auth, :@_action, :@_method, :@_tag, :@_params].each_with_index do |k, i|
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
      action && method && METHODS.include?(method) && auth.valid?
    end

    def to_yaml
      YAML.dump([
        id,
        auth,
        action,
        method,
        tag,
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

      data = params.to_hash
      data = data.to_json if key == :body && auth.json

      client.public_send(method, action, key => data)
    end

    def url
      @_url ||= [client.base_uri, action]
    end

    def action
      @_action ||= compose_action(raw_request.params[Params::ACTION])
    end

    def method
      @_method ||= compose_method(raw_request.params[Params::METHOD])
    end

    def tag
      @_tag ||= compose_tag(raw_request.params[Params::TAG])
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

    def compose_tag(tag)
      if tag
        tag.downcase.to_sym
      else
        TAG
      end
    end

    def params
      @_params ||= Params.new(raw_params, collection)
    end

    def auth
      @_auth ||= Authentication.new(raw_request, tag)
    end

    def raw_params
      @_raw_params ||= raw_request.params
    end

    def client
      @_client ||= Client.new(auth)
    end
  end
end
