module CabbageDoc
  module Processors 
    class Documentation < Processor
      def perform
        collection.clear!

        Configuration.instance.controllers.call.each do |filename|
          collection.parse!(filename)
        end

        collection.save!
      end
    end
  end
end
