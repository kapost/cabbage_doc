require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

module CabbageDoc
  module Markdown
    class HighlightedHTML < Redcarpet::Render::HTML
      include Rouge::Plugins::Redcarpet
    end

    class << self
      def new
        Redcarpet::Markdown.new(
          HighlightedHTML.new,
          tables: true,
          fenced_code_blocks: true,
          disable_indented_code_blocks: true,
          autolink: true,
          no_intra_emphasis: true,
          strikethrough: true,
          space_after_headers: true,
          with_toc_data: true,
          hard_wrap: true
        )
      end
    end
  end
end
