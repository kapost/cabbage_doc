module CabbageDoc
  class Controller
    include Parser

    attr_reader :label, :klass, :name, :path, :actions

    def initialize
      @actions = []
    end

    def parse(filename)
      text = File.read(filename) rescue nil
      return false unless text

      @label, @klass = parse_label_and_class(text)
      return unless @label && @klass

      @name = @label.downcase
      @path = Path.join('/', Configuration.instance.path, @name)

      @actions = parse_actions(text)

      valid?
    end

    def valid?
      @name && @actions.any?
    end

    def find_action(method, path)
      @actions.detect do |action| 
        action.method == method && action.path == path
      end
    end

    private

    def compose_class(klass)
      [Configuration.instance.namespace, klass].compact.join('::')
    end

    def compose_label(klass)
      klass.sub(/Controller$/, '')
    end

    def parse_label_and_class(text)
      klass = parse_class(text)
      return unless klass

      [compose_label(klass), compose_class(klass)]
    end

    def parse_actions(text)
      actions = []

      text.scan(/(#\s*Public:\s*.*?def\s*.*?\s*#\s*#{MARKER})/m) do
        actions << Action.parse($1.strip)
      end 

      actions.compact
    end

    def parse_class(text)
      m = text.match(/class\s+(.*?)\s+?#\s+?#{MARKER}$/)
      m[1].strip.split('<').first.strip if m
    end
  end
end
