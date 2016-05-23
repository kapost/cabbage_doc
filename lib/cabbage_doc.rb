module CabbageDoc
  MARKER = ':cabbagedoc:'.freeze

  autoload :Path,           'cabbage_doc/path'
  autoload :Singleton,      'cabbage_doc/singleton'
  autoload :Cloneable,      'cabbage_doc/cloneable'
  autoload :PactoHelper,    'cabbage_doc/pacto_helper'
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
  autoload :Processor,      'cabbage_doc/processor'
  autoload :Customizer,     'cabbage_doc/customizer'
  autoload :Task,           'cabbage_doc/task'

  class << self
    def configure
      Configuration.instance.tap do |config|
        yield config if block_given?
        config.validate!
      end
    end
  end
end
