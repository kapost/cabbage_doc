module CabbageDoc
  class Cache
    def initialize
      clear
    end

    def write(key, value, options = {})
      @_data[key] = value
    end

    def read(key)
      @_data[key]
    end

    def delete(key)
      @_data.delete(key)
    end

    def clear
      @_data = {}
    end
  end
end
