module CabbageDoc
  class Action
    include Parser

    METHODS = %w(GET POST PUT DELETE).freeze
    METHODS_REGEXP = METHODS.join('|').freeze
    SECTION_REGEXP = "Parameters|Examples|#{METHODS_REGEXP}|#{VISIBILITY_REGEXP}".freeze

    attr_reader :label, :name, :description, :path, :method, :parameters, :examples, :visibility

    def initialize
      @parameters = []
      @examples = []
      @visibility = VISIBILITY.first
    end

    def parse(text, tag = TAG)
      @method, @path = parse_method_and_path(text)
      return unless valid?

      @name = parse_name(text)
      @label = parse_label(text)
      @description = parse_description(text)
      @visibility = parse_visibility(text)

      @parameters, @examples = parse_parameters_and_examples(text)

      valid?
    end

    def valid?
      @method && @path
    end

    def param?(key)
      @parameters.any? { |parameter| parameter.name =~ /#{key}/ }
    end

    private

    def parse_parameters_and_examples(text)
      # FIXME: rewrite this to do a 'scan' with the right Regexp
      parameters = []
      examples = []

      lines = text_to_lines(text).map(&:strip).select { |line| line.size > 0 }

      lines.each do |line|
        if parameter = Parameter.parse(line)
          parameters << parameter
        elsif example = Example.parse(line)
          examples << example
        end
      end

      [parameters, examples]
    end

    def parse_method_and_path(text)
      m = text.match(/#\s*(#{METHODS_REGEXP}):\s*(.*?)$/)
      [m[1].strip.upcase, m[2].strip] if m
    end

    def parse_name(text)
      m = text.match(/def\s+(.*?)\s*#\s*#{MARKER}$/)
      m[1].strip if m
    end

    def parse_label(text)
      m = text.match(/#\s*(#{VISIBILITY_REGEXP}):(.*?)$/)
      m[2].strip if m
    end

    def parse_description(text)
      m = text.match(/#\s*Description:\s+(.*?)(#\s*(#{SECTION_REGEXP}):|\z)/m)
      text_to_lines(m[1]).join("\n").strip if m
    end

    def parse_visibility(text)
      m = text.match(/#\s*(#{VISIBILITY_REGEXP}):(.*?)$/)
      if m
        m[1].strip.downcase.to_sym
      else
        VISIBILITY.first
      end
    end

    def text_to_lines(text)
      text.strip.gsub(/\r\n?/, "\n").split("\n").map do |line|
        line.sub!(/^(\s+)?#\s*/, "")
        line if line !~ /#\s+?#{MARKER}$/
      end.compact
    end
  end
end
