require 'yaml'

module CabbageDoc
  class Response
    attr_reader :url, :headers, :params, :code, :body

    class << self
      def parse(s)
        YAML.load(s)
      end
    end

    def initialize(url, params, response)
      @url = url
      @params = params
      @headers = convert_headers(response)
      @code = response.code
      @body = response.parsed_response
    end

    def to_yaml
      YAML.dump(self)
    end

    def to_json
      { 
        url: url,
        query: params.to_query, 
        code: code, 
        headers: prettify(headers),
        body: prettify(body) 
      }.to_json
    end

    private

    def prettify(data)
      JSON.pretty_generate(data)
    rescue
      data.to_s
    end

    def convert_headers(response)
      {}.tap do |hash|
        response.headers.each do |k, v|
          hash[k] = v
        end
      end
    end
  end
end
