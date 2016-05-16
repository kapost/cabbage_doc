module CabbageDoc
  module WebHelper
    def config
      Configuration.instance
    end

    def collection
      @_collection ||= Collection.instance.tap do |collection|
        collection.load!
      end
    end

    def markdown
      @_markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
    end

    def title
      @_title ||= config.title
    end

    def auth
      @_auth ||= Authentication.new(request)
    end
  end
end
