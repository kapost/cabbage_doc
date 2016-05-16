module CabbageDoc
  class Params
    include Enumerable

    def initialize(params, collection)
      @_params = convert(params, collection)
    end

    def each
      @_params.each do |k, v|
        yield(k, v)
      end
    end

    def delete(key)
      @_params.delete(key)
    end

    def find(key)
      @_params[key]
    end

    def valid?
      @_params.any?
    end

    def to_hash
      @_params
    end

    def to_query
      @_params.map do |k, v|
        if v.is_a?(Array)
          v.map { |vv| "#{k}[]=#{CGI.escape(vv)}" }
        else
          "#{k}=#{CGI.escape(v)}"
        end
      end.flatten.join('&')
    end

    private

    def convert(params, collection)
      method = params['method']
      action = params['action']

      return {} unless action && method

      action = collection.find_action(method, action)
      return {} unless action

      {}.tap do |hash|
        params.each do |k, v|
          hash[k] = v if action.param?(k.sub(/\[\]$/, ''))
        end
      end
    end
  end
end
