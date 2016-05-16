module CabbageDoc
  class Path
    class << self
      def join(*args)
        args.join('/').gsub(/\/+/, '/')
      end
    end
  end
end
