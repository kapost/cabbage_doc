module CabbageDoc
  module Generators
    class Pages < Generator
      priority :medium

      def perform
        Dir.glob(File.join(config.root, config.page_root, "*.#{config.page_ext}")).each do |file|
          open(file.sub(/#{config.page_ext}$/, 'html'), 'w') do |f|
            f.write(helper.markdown.render(File.read(file)))
          end
        end
      end

      private

      class Helper
        include CabbageDoc::WebHelper
      end

      def helper
        @_helper ||= Helper.new
      end
    end
  end
end
