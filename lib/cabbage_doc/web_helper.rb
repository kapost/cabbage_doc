require 'erb'
require 'redcarpet'

module CabbageDoc
  module WebHelper
    def asset_path(path)
      [config.asset_path || request.path, path].join('/').gsub(/\/\/+/, '/')
    end

    def theme_path
      asset_path("css/highlight/#{config.theme}.css")
    end

    def config
      Configuration.instance
    end

    def collection
      if config.dev && config.auto_generate
        Generator.perform(:all)
        @_collection = nil
      end

      @_collection ||= Collection.instance.tap do |collection|
        collection.load!
      end
    end

    def markdown
      @_markdown ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new,
        tables: true,
        fenced_code_blocks: true,
        autolink: true
      )
    end

    def eval_with_erb(text)
      ERB.new(text).result(binding)
    end

    def title
      @_title ||= config.title
    end

    def auth
      @_auth ||= Authentication.new(request)
    end

    def visible?(o)
      auth.visibility.include?(o.visibility)
    end

    def tag_visible?(tag)
      config.tags.size <= 1 || auth.visibility.include?(tag)
    end

    def format_visibility(o)
      o.visibility.to_s.capitalize if o.visibility != VISIBILITY.first
    end

    def format_tag(tag)
      tag.to_s.capitalize
    end

    def post_request
      @_post_request ||= Request.new(request, collection)
    end

    def response_by_id(id)
      response = Worker.get(id)

      if response.is_a?(Response)
        content_type :json
        response.to_json
      else
        status 503
        content_type :json
        { id: id }.to_json
      end
    end
  end
end
