require 'yaml'

module CabbageDoc
  class Collection
    include Singleton
    include Enumerable

    FILENAME = "controllers.yml".freeze

    def initialize
      @_controllers = []
    end

    def <<(controller)
      @_controllers << controller
    end

    def find_action(method, path)
      action = nil

      @_controllers.each do |controller|
        action = controller.find_action(method, path)
        break if action
      end

      action
    end

    def each
      @_controllers.each do |controller|
        yield controller
      end
    end

    def parse!(filename, tag = TAG)
      text = File.read(filename) rescue nil
      return false unless text

      controller = Controller.parse(text, tag)
      return false unless controller

      controllers = controller.eval(text, tag)

      @_controllers.concat(controllers)

      controllers.any?
    end

    def clear!(tag = nil)
      if tag && tags?
        @_controllers.reject! { |controller| tag == controller.tag }
      else
        @_controllers = []
      end
    end

    def load!
      @_controllers = YAML.load(File.read(filename)) rescue [] unless @_controllers.any?
    end

    def save!
      sort!
      open(filename, 'w') { |f| f.write(YAML.dump(@_controllers)) } rescue nil
    end

    private

    def tags?
      @_tags ||= config.tags.size > 1
    end

    def sort!
      return unless tags?

      @_controllers.sort! do |controller|
        -config.tags.index(controller.tag)
      end
    end

    def config
      @_config ||= Configuration.instance
    end

    def filename
      @_filename ||= Path.join(config.root, FILENAME)
    end
  end
end
