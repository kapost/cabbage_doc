module CabbageDoc
  module Generators
    class Pages < Generator
      priority :low

      def perform
        pages.each do |file|
          generate(file)
        end
      end

      private

      def generate(file)
        open(file.sub(/#{config.page_ext}$/, 'html'), 'w') do |f|
          f.write(helper.markdown.render(File.read(file)))
        end
      end

      def pages
        @_pages ||= Dir.glob(File.join(config.root, config.page_root, "*.#{config.page_ext}"))
      end

      class Helper
        include CabbageDoc::WebHelper
      end

      def helper
        @_helper ||= Helper.new
      end
    end
  end
end
