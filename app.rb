require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongo'
require 'mongoid'
require 'pusher'

require './models/user'
require './models/session'

# Mongoid設定
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('bootstrap_haml')
end

# Pusher設定
Pusher.app_id = '18646'
Pusher.key = '651405108b80e1c1ace7'
Pusher.secret = 'a018238daee0c9d722e6'

class MySinatraApp < Sinatra::Base
  get '/' do
    topbar = haml :topbar
    haml :container_app, {}, :topbar => topbar
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
  
  get '/test_pusher' do
    Pusher['my-channel'].trigger('my-event', {:message => 'hello world'})
    topbar = haml :topbar
    haml :container_app, {}, :topbar => topbar
  end
end
