module CabbageDoc
  class Parameter
    include Parser

    TYPES = %i(numeric decimal integer string id enumeration array date time timestamp hash)

    attr_reader :label, :name, :type, :type_label, :default, :values, :required

    def initialize
      @values = []
    end

    def parse(text)
      m = text.match(/^(.*?\s+\(.*?\).*?)\s+-\s+(.*?)$/)
      return false unless m

      @name, @type_label, @required = parse_name_type_required(m[1].strip)
      @type = @type_label.downcase.to_sym if @type_label

      @required = !!@required

      @label, @default, @values = parse_label_default_values(m[2].strip)
      @values ||= []

      valid?
    end

    def valid?
      @type && TYPES.include?(@type)
    end

    private

    def parse_label_default_values(text)
      m = text.match(/^(.*?)\s*(\(.*?\))?$/)
      return unless m

      index, options = parse_options(text)

      arr = [text[0..index-1].strip]

      if options.any?
        arr << options[:default]
        arr << Array(options[:values])
      end

      arr
    end

    def parse_name_type_required(text)
      text.split(/\s+/).map(&:strip).map do |component|
        if component =~ /^\((.*?)\)$/
          $1
        elsif component =~ /\[required\]/i
          true
        else
          component
        end
      end
    end

    def parse_options(text)
      m = text.match(/:.*?\)$/)
      return [0, {}] unless m

      index = text.rindex('(')
      return [0, {}] unless index
      
      [index, parse_option(text[index..-1].strip)]
    end
  end
end
