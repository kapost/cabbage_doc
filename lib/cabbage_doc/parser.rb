module CabbageDoc
  module Parser
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def parse(text, tag = TAG)
        instance = new
        instance if instance.parse(text, tag)
      end
    end

    def parse(text, tag = TAG)
      raise NotImplementedError
    end

    def parse_option(text)
      m = text.match(/^\((.*?)\)$/)
      return {} unless m

      {}.tap do |hash|
        m[1].split(/,/).map(&:strip).each do |o|
          k, v = o.split(':').map(&:strip)
          next unless k && v

          v = v.split('|').map(&:strip)
          v = v.first if v.size == 1

          hash[k.to_sym] = v
        end
      end
    end

    def parse_templates(text)
      templates = []

      text.scan(/(\{(.*?)\})/) do
        templates << { text: $1, values: $2.split(/,/).map(&:strip) }
      end

      templates
    end
  end
end
