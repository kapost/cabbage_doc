module CabbageDoc
  TAG = :api
  MARKER = ':cabbagedoc:'.freeze
  VISIBILITY = %i(public private internal beta unreleased).freeze
  VISIBILITY_REGEXP = VISIBILITY.map(&:to_s).map(&:capitalize).join('|').freeze

  autoload :Path,           'cabbage_doc/path'
  autoload :Singleton,      'cabbage_doc/singleton'
  autoload :Cloneable,      'cabbage_doc/cloneable'
  autoload :Parser,         'cabbage_doc/parser'
  autoload :Client,         'cabbage_doc/client'
  autoload :Request,        'cabbage_doc/request'
  autoload :Response,       'cabbage_doc/response'
  autoload :Params,         'cabbage_doc/params'
  autoload :Example,        'cabbage_doc/example'
  autoload :Configuration,  'cabbage_doc/configuration'
  autoload :Authentication, 'cabbage_doc/authentication'
  autoload :Parameter,      'cabbage_doc/parameter'
  autoload :Action,         'cabbage_doc/action'
  autoload :Controller,     'cabbage_doc/controller'
  autoload :Collection,     'cabbage_doc/collection'
  autoload :WebHelper,      'cabbage_doc/web_helper'
  autoload :Web,            'cabbage_doc/web'
  autoload :Generator,      'cabbage_doc/generator'
  autoload :Customizer,     'cabbage_doc/customizer'
  autoload :Task,           'cabbage_doc/task'
  autoload :Worker,         'cabbage_doc/worker'
  autoload :Cache,          'cabbage_doc/cache'
  autoload :Markdown,       'cabbage_doc/markdown'
  autoload :Highlighter,    'cabbage_doc/highlighter'

  class << self
    def configure
      Configuration.instance.tap do |config|
        yield config if block_given?
        config.validate!
      end
    end

    def glob(*args)
      proc do
        arr = args.first
        arr = [args] unless arr.is_a?(Array)
        arr.map { |segs| Dir.glob(File.join(*Array(segs))) }.flatten.sort.reverse
      end
    end
  end
end
