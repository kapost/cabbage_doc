module CabbageDoc
  module Worker
    EXPIRES_IN = 60.freeze # 60 seconds

    class << self
      def get(id)
        response = CabbageDoc::Configuration.instance.cache.read([CabbageDoc::MARKER, id].join('_'))
        Response.parse(response) if response
      end
    end

    def perform(serialized_request)
      request = Request.parse(serialized_request)
      response = request.perform
      write(request.id, response) if response
    end

    private

    def write(id, response)
      CabbageDoc::Configuration.instance.cache.write(
        [CabbageDoc::MARKER, id].join('_'), 
        response.to_yaml,
        expires_in: EXPIRES_IN
      )
    end
  end
end
