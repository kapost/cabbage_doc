module CabbageDoc
  class Controller
    include Parser
    include Cloneable

    attr_reader :label, :klass, :name, :path, :actions, :visibility, :tag

    def initialize(tag = TAG)
      @actions = []
      @visibility = VISIBILITY.first
      @tag = tag
    end

    def parse(text, tag = TAG)
      @label, @path, @klass, @visibility, @tag = parse_label_path_class_visibility_and_tag(text, tag)
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

    def eval(text, tag)
      return [self] unless template?

      templates = {}

      templates.merge!(parse_templates(path, tag))
      templates.merge!(parse_templates(label, tag))

      yield_actions(text) do |action|
        templates.merge!(parse_templates(action, tag))
      end

      return [] unless templates.any?

      count = templates.values.first.count
      return [] if templates.values.any? { |v| v.count != count }

      count.times.map do |i|
        template_text = text.dup

        templates.each do |text, values|
          template_text.gsub!(text, values.shift.to_s)
        end

        self.class.parse(template_text, tag)
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

    def compose_visbility(metadata)
      metadata[:visibility] || VISIBILITY.first
    end

    def compose_tag(metadata, tag = TAG)
      metadata[:tag]&.to_sym || tag
    end

    def parse_label_path_class_visibility_and_tag(text, tag = TAG)
      klass = parse_class(text)
      return unless klass

      metadata = parse_metadata(text)

      [
        compose_label(metadata, klass),
        compose_path(metadata, klass),
        klass,
        compose_visbility(metadata),
        compose_tag(metadata, tag)
      ]
    end

    def parse_actions(text)
      actions = []

      yield_actions(text) do |action|
        actions << Action.parse(parse_action(action))
      end

      actions.compact
    end

    def parse_action(text)
      new_text = text.strip

      if new_text.scan(/#\s*(#{VISIBILITY_REGEXP}):\s*/).size > 1
        new_text.sub(/#\s*(#{VISIBILITY_REGEXP}):.*?#\s*(#{VISIBILITY_REGEXP}):/m, '# \2:').strip
      else
        new_text
      end
    end

    def parse_class(text)
      m = text.match(/class\s+(.*?)\s+?#\s+?#{MARKER}$/)
      m[1].strip.split('<').first.strip if m
    end

    def parse_metadata(text)
      m = text.match(/(#\s*(#{VISIBILITY_REGEXP}):\s*.*?class\s+.*?\s*#\s*#{MARKER})/m)
      return {} unless m

      metadata = m[1].strip

      {}.tap do |hash|
        m = metadata.match(/#\s*(#{VISIBILITY_REGEXP}):(.*?)$/)
        if m
          hash[:visibility] = parse_visibility(m[1])
          hash[:label] = m[2].strip
        end

        m = metadata.match(/#\s*PATH:\s*\/(.*?)$/)
        hash[:path] = m[1].strip if m
      end
    end

    def parse_visibility(text)
      visibility = text.to_s.strip.downcase
      if visibility.size > 0
        visibility.to_sym
      else
        VISIBILITY.first
      end
    end

    def yield_actions(text)
      text.scan(/(#\s*(#{VISIBILITY_REGEXP}):\s*.*?(#{Action::METHODS_REGEXP}):.*?def\s+.*?\s*#\s*#{MARKER})/m) do
        yield $1
      end 
    end

    def actions?
      @actions.any?
    end

    def template?
      @path =~ /\/\{.*?\}/ || @label =~ /\{.*?\}/
    end
  end
end
