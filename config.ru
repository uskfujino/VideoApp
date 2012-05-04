require 'rubygems'
require 'bundler'

Bundler.require

#require 'app'
require './app'

map '/assets' do
  # Sprockets calls coffeescript directly 
  # so we must use 'bare' option
  Tilt::CoffeeScriptTemplate.default_bare = true
  
  environment = Sprockets::Environment.new
  environment.append_path 'public/js'
  run environment
end

map '/' do
  run MainApp
end
