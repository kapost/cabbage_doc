module CabbageDoc
  module Generators
    class Api < Generator
      priority :high

      def perform
        collection.clear!

        if controllers.is_a?(Hash)
          parse_with_tag!
        else
          parse_without_tag!
        end

        collection.save!
      end

      private

      def parse_with_tag!
        controllers.each do |tag, filenames|
          next unless filenames.respond_to?(:call)

          filenames.call.each do |filename|
            collection.parse!(filename, tag)
          end
        end
      end

      def parse_without_tag!
        controllers.each do |filename|
          collection.parse!(filename)
        end
      end
    end
  end
end
