module CabbageDoc
  module Processors 
    class Documentation < Processor
      def perform
        collection.clear!

        Configuration.instance.controllers.call.each do |filename|
          if controller = Controller.parse(filename)
            collection << controller
          end
        end

        collection.save!
      end
    end
  end
end
