module CabbageDoc
  module Processors 
    class Documentation < Processor
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
