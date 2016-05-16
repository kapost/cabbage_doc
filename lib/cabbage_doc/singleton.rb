module CabbageDoc
  module Singleton
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def instance
        @_instance ||= new
      end
    end
  end
end
