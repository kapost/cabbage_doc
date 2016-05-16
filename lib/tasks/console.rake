desc 'Open IRB console for gem development environment'
task :console do
  require 'irb'
  require 'cabbage_doc'
  ARGV.clear
  IRB.start
end
