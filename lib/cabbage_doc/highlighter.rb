require 'rouge'

module CabbageDoc
  class Highlighter
    attr_accessor :formatter, :lexers

    def initialize(options = {})
      self.formatter = Rouge::Formatters::HTMLLegacy.new({ css_class: 'highlight' }.merge(options))
      self.lexers = {}
    end

    def format(text, type = 'txt')
      formatter.format(find_lexer(text, type).lex(text))
    end

    private

    def find_lexer(text, type)
      self.lexers[type.to_sym] ||= Rouge::Lexer.guess(source: text,
                                                      filename: "highlight.#{type}").new
    end
  end
end
