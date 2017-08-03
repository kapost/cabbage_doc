require 'rake'
require 'rake/tasklib'

module CabbageDoc
  class Task < Rake::TaskLib
    attr_accessor :generators, :tags, :name, :customize, :confirm

    def self.define
      new.tap do |instance|
        yield instance if block_given?
        instance.validate!
        instance.sort!
        instance.define!
      end
    end

    def initialize
      self.generators = config.generators.dup
      self.tags = config.tags.dup
      self.name = :cabbagedoc
      self.customize = true
      self.confirm = config.confirm
    end

    def config
      @_config ||= Configuration.instance
    end

    def sort!
      generators.sort! { |generator| Generator::PRIORITIES.index(Generator.all[generator].priority) }
    end

    def define!
      namespace name do
        define_generators!
        define_customizer!
      end

      desc "Run all generators"
      task name => :environment do
        generators.each do |type|
          Generator.perform(type)
        end
      end
    end

    def validate!
      fail "Invalid 'name'" unless name.is_a?(Symbol)
      fail "No 'generators' configured" unless generators.any?

      generators.each do |generator|
        fail "Invalid 'generator' #{generator}" unless Generator.exists?(generator)
      end
    end

    private

    def define_generators!
      generators.each do |type|
        desc "Generate #{type}"
        task type => :environment do
          Generator.perform(type) if confirm.call(:all)
        end

        define_generators_by_tag!(type)
        define_customizer!
      end
    end

    def define_generators_by_tag!(type)
      return unless Generator.supports?(type, :tags)
      return unless tags.size > 1

      namespace type do
        tags.each do |tag|
          desc "Generate #{type} for #{tag}"
          task tag => :environment do
            Generator.perform(type, tag) if confirm.call(tag)
          end
        end
      end
    end

    def define_customizer!
      return unless customize

      desc "Customize Web UI"
      task :customize => :environment do
        Customizer.new.perform
      end
    end
  end
end
