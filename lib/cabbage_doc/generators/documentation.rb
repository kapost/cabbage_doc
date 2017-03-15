module CabbageDoc
  module Generators
    class Documentation < Generator
      priority :high

      def perform
        collection.clear!

        config.controllers.call.each do |filename|
          collection.parse!(filename)
        end

        collection.save!
      end
    end
  end
end
