require 'yaml'

module CabbageDoc
  class Response
    attr_reader :url, :headers, :params, :code, :body

    class << self
      def parse(s, tag = TAG)
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
        url: highlight(url.join),
        query: highlight(params.to_query),
        code: highlight(code.to_s),
        headers: highlight(prettify(headers), :json),
        body: highlight(prettify(body), :json)
      }.to_json
    end

    private

    def highlight(text, type = :sh)
      highlighter.format(text, type)
    end

    def highlighter
      @_highlighter ||= Highlighter.new
    end

    def prettify(text)
      JSON.pretty_generate(text)
    rescue
      text.to_s
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
