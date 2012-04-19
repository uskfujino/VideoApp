require './models/user'
require './models/session'
require 'logger'
require 'pp'

DebugLog = Logger.new('debug.log')
DebugLog.info "debug.log created"

# Mongoid設定
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('bootstrap_haml')
end

# Pusher設定
Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_APP_KEY']
Pusher.secret = ENV['PUSHER_APP_SECRET']

class MySinatraApp < Sinatra::Base
  use Rack::Session::Cookie,
  #  :key => 'rack.session',
  #  :domain => 'localhost',
  #  :path => '/',
    :expire_after => 60*60*24*14, #2weeks
    :secret => 'uskfujino'

  #use OmniAuth::Strategies::Developer
  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  end

  get '/' do
    topbar = haml :topbar, {}, :twitter_user_name => session['twitter_user_name']
    haml :container_app, {}, :topbar => topbar, :pusher_key => Pusher.key, :twitter_user_name => session['twitter_user_name']
  end

  # Twitter認証成功時に呼ばれる
  get '/auth/twitter/callback' do
    session['twitter_user_name'] = request.env['omniauth.auth']
    auth = request.env['omniauth.auth']
    session['twitter_user_name'] = auth['info']['nickname']
    #login(auth_hash)
    redirect '/'
  end

  get '/signup/failure' do
    topbar = haml :topbar, {}, :twitter_user_name => session['twitter_user_name']
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
    topbar = haml :topbar, {}, :twitter_user_name => session['twitter_user_name']
    haml :signup, {}, :error_message => '', :topbar => topbar
  end
  
  get '/test_pusher' do
    Pusher['my_channel'].trigger('my_event', {:message => 'hello world'})
    topbar = haml :topbar, {}, :twitter_user_name => session['twitter_user_name']
    haml :container_app, {}, :topbar => topbar, :pusher_key => Pusher.key, :twitter_user_name => session['twitter_user_name']
  end

  # 無効なパスはすべてルートへ転送
  get '/*' do
    redirect '/'
  end
end
