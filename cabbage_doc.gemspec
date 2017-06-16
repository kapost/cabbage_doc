$:.unshift File.expand_path('../lib', __FILE__)
require 'cabbage_doc/version'

Gem::Specification.new do |s|
  s.name          = 'cabbage_doc'
  s.version       = CabbageDoc::VERSION
  s.summary       = 'Interactive API documentation generator.'
  s.description   = 'A lean and mean *interactive API* documentation generator.'
  s.authors       = ['Mihail Szabolcs']
  s.email         = 'szaby@kapost.com'
  s.files         = Dir.glob('{lib,web}/**/*.{rb,css,js,haml}')
  s.licenses      = 'MIT'
  s.homepage      = 'https://github.com/kapost/cabbage_doc'
  s.require_paths = ['lib']

  s.required_ruby_version = ">= 2.1"
 
  s.add_dependency 'redcarpet'
  s.add_dependency 'haml', '~> 4.0.6'
  s.add_dependency 'sinatra'
  s.add_dependency 'httparty', '~> 0.15.0'
  s.add_dependency 'json'
  s.add_dependency 'rake', '>= 10.0'

  s.add_development_dependency 'bundler', '~> 1.11'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rubygems-tasks'
end
