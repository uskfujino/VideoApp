require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongoid'

require './models/user'
require './models/session'

# Mongoid設定
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('bootstrap_haml')
end

get '/' do
  haml :container_app
end

get '/signup/failure' do
  topbar = haml :topbar
  haml :signup, {}, :error_message => 'Input Data is incorrect.', :topbar => topbar
end

post '/signup/confirm' do
  user_id = params[:post][:user_id]
  user_name = params[:post][:user_name]

  if user_id == '' || user_id == nil
    redirect '/signup/failure'
    #haml :signup, {}, :error_message => 'User%20ID%20is%20Blank'
    #return
  end
  if user_name == '' || user_name == nil
    redirect '/signup/failure'
    #haml :signup, {}, :error_message => 'User%20Name%20is%20Blank'
    #return
  end
  
  User.create(login_id: user_id, name: user_name)

  redirect '/'
end

get '/signup' do
  topbar = haml :topbar
  haml :signup, {}, :error_message => '', :topbar => topbar
end

