module CabbageDoc
  class Controller
    include Parser
    include Cloneable

    attr_reader :label, :klass, :name, :path, :actions

    def initialize
      @actions = []
    end

    def parse(text)
      @label, @path, @klass = parse_label_path_and_class(text)
      return false unless @label && @klass

      @name = compose_name(klass)

      @actions = parse_actions(text) unless template?

      valid?
    end

    def valid?
      @name && (actions? || template?)
    end

    def find_action(method, path)
      @actions.detect do |action| 
        action.method == method && action.path == path
      end
    end

    def eval(text)
      return [self] unless template?

      templates = []

      templates += parse_templates(@path)
      templates += parse_templates(@label)

      return [] unless templates.any?

      count = templates.first[:values].count

      (1..count).map do |i|
        template_text = text.dup

        templates.each do |template|
          template_text.gsub!(template[:text], template[:values].shift.to_s)
        end

        self.class.parse(template_text)
      end.compact
    end

    private

    def compose_label(metadata, klass)
      metadata[:label] || klass.sub(/Controller$/, '')
    end

    def compose_path(metadata, klass)
      Path.join('/', Configuration.instance.path, metadata[:path] || compose_name(klass))
    end

    def compose_name(klass)
      compose_label({}, klass).downcase
    end

    def parse_label_path_and_class(text)
      klass = parse_class(text)
      return unless klass

      metadata = parse_metadata(text)

      [compose_label(metadata, klass), compose_path(metadata, klass), klass]
    end

    def parse_actions(text)
      actions = []

      text.scan(/(#\s*Public:\s*.*?(#{Action::METHODS_REGEXP}):.*?def\s+.*?\s*#\s*#{MARKER})/m) do
        actions << Action.parse($1.strip)
      end 

      actions.compact
    end

    def parse_class(text)
      m = text.match(/class\s+(.*?)\s+?#\s+?#{MARKER}$/)
      m[1].strip.split('<').first.strip if m
    end

    def parse_metadata(text)
      m = text.match(/(#\s*Public:\s*.*?class\s+.*?\s*#\s*#{MARKER})/m)
      return {} unless m

      metadata = m[1].strip

      {}.tap do |hash|
        m = metadata.match(/#\s*Public:(.*?)$/)
        hash[:label] = m[1].strip if m

        m = metadata.match(/#\s*PATH:\s*\/(.*?)$/)
        hash[:path] = m[1].strip if m
      end
    end

    def actions?
      @actions.any?
    end

    def template?
      @path =~ /\/{.*?,.*?}/
    end
  end
end
