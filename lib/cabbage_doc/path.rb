module CabbageDoc
  class Path
    class << self
      def join(*args)
        args.join('/').gsub(/\/+/, '/').gsub(/\/+$/, '')
      end
    end
  end
end
