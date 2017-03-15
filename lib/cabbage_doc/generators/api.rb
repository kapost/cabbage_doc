module CabbageDoc
  module Generators
    class Api < Generator
      priority :high

      def perform
        collection.clear!

        controllers.each do |filename|
          collection.parse!(filename)
        end

        collection.save!
      end
    end
  end
end
