Dir.glob(File.join(File.dirname(__FILE__), 'lib', 'tasks', '*.rake')).each { |file| load file }

require 'rubygems/tasks'
Gem::Tasks.new

task default: %w[spec]
