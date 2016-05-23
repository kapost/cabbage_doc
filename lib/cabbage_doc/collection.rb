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

    def parse!(filename)
      text = File.read(filename) rescue nil
      return false unless text

      controller = Controller.parse(text)
      return false unless controller

      controllers = controller.eval(text)

      @_controllers.concat(controllers)

      controllers.any?
    end

    def clear!
      @_controllers = []
    end

    def load!
      @_controllers = YAML.load(File.read(filename)) rescue [] unless @_controllers.any?
    end

    def save!
      open(filename, 'w') { |f| f.write(YAML.dump(@_controllers)) } rescue nil
    end

    private

    def filename
      @_filename ||= Path.join(Configuration.instance.root, FILENAME)
    end
  end
end
