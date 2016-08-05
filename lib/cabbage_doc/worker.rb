module CabbageDoc
  module Worker
    EXPIRES_IN = 30.freeze # 30 seconds

    class << self
      def get(id)
        cache_id = [CabbageDoc::MARKER, id].join('_')
        response = CabbageDoc::Configuration.instance.cache.read(cache_id)

        if response
          CabbageDoc::Configuration.instance.cache.delete(cache_id)
          Response.parse(response)
        end
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
