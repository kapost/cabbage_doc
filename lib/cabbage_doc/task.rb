require 'rake'
require 'rake/tasklib'

module CabbageDoc
  class Task < Rake::TaskLib
    attr_accessor :processors, :name

    def self.define
      new.tap do |instance|
        yield instance if block_given?
        instance.validate!
        instance.sort!
        instance.define!
      end
    end

    def initialize
      @processors = [:documentation]
      @name = :cabbagedoc
    end

    def sort!
      processors.sort! { |processor| Processor::PRIORITIES.index(Processor.all[processor].priority) }
    end

    def define!
      namespace name do
        processors.each do |processor|
          desc "Process #{processor}"
          task processor.to_s => :environment do
            Processor.all[processor].new.perform
          end
        end

        desc "Customize Web"
        task :customize => :environment do
          Customizer.new.perform
        end
      end

      desc "Run all processors"
      task name => :environment do
        processors.each do |name|
          Processor.all[name].new.perform
        end
      end
    end

    def validate!
      fail "Invalid 'name'" unless name.is_a?(Symbol)
      fail "No 'processors' configured" unless processors.any?

      processors.each do |processor|
        fail "Invalid 'processor' #{processor}" unless Processor.all.has_key?(processor)
      end
    end
  end
end
