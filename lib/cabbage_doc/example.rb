module CabbageDoc
  class Example
    include Parser

    attr_reader :label, :params

    def initialize
      @params = {}
    end

    def parse(text)
      m = text.match(/^(.*?)\s+-\s+(\(.*?\))$/)
      return false unless m

      @label = m[1].strip
      @params = parse_option(m[2].strip)

      valid?
    end

    def valid?
      !@label.nil?
    end
  end
end
