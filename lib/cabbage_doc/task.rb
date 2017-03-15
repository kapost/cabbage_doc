require 'rake'
require 'rake/tasklib'

module CabbageDoc
  class Task < Rake::TaskLib
    attr_accessor :generators, :name

    def self.define
      new.tap do |instance|
        yield instance if block_given?
        instance.validate!
        instance.sort!
        instance.define!
      end
    end

    def initialize
      @generators = Configuration.instance.generators
      @name = :cabbagedoc
    end

    def sort!
      generators.sort! { |generator| Generator::PRIORITIES.index(Generator.all[generator].priority) }
    end

    def define!
      namespace name do
        generators.each do |type|
          desc "Generate #{type}"
          task type => :environment do
            Generator.perform(type)
          end
        end

        desc "Customize Web UI"
        task :customize => :environment do
          Customizer.new.perform
        end
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
  end
end
