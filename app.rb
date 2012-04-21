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
    haml :container_app, {}, :topbar => create_topbar_closed, :pusher_key => Pusher.key, :twitter_user_name => session['twitter_user_name']
  end

  #get '/#' do
  #  DebugLog.info '/# called'
  #  haml :container_app, {}, :topbar => create_topbar_opened, :pusher_key => Pusher.key, :twitter_user_name => session['twitter_user_name']
  #end
  
  # Twitter認証成功時に呼ばれる
  get '/auth/twitter/callback' do
    auth = request.env['omniauth.auth']
    session['twitter_user_name'] = auth['info']['nickname']
    session['twitter_user_id'] = auth['uid']
    #login(auth_hash)
    if logged_in?
      DebugLog.info "Logged in!"
    end
    redirect '/'
  end

  def logout
    session['twitter_user_name'] = nil
    session['twitter_user_id'] = nil
  end

  def logged_in?
    session['twitter_user_name'] != nil && session['twitter_user_id'] != nil
  end

  def create_topbar_closed
    create_topbar(false)
  end
  
  def create_topbar_opened
    DebugLog.info 'create_topbar_opened called'
    create_topbar(true)
  end

  def create_topbar(dropdown_opened)
    if dropdown_opened == true
      DebugLog.info "dropdown opened"
    else
      DebugLog.info "dropdown closed"
    end
    dropdown = haml :dropdown, {}, :opened => dropdown_opened
    haml :topbar, {}, :twitter_user_name => session['twitter_user_name'], :dropdown => dropdown
  end
  
  get '/logout' do
    logout
    redirect '/'
  end

  get '/signup/failure' do
    haml :signup, {}, :error_message => 'Input Data is incorrect.', :topbar => create_topbar_closed
  end
  
  post '/signup/confirm' do
    user_id = params[:post][:user_id]
    user_name = params[:post][:user_name]
  
    if user_id == '' || user_id == nil
      redirect '/signup/failure'
    end
    if user_name == '' || user_name == nil
      redirect '/signup/failure'
    end
    
    User.create(login_id: user_id, name: user_name)
  
    redirect '/'
  end
  
  get '/signup' do
    haml :signup, {}, :error_message => '', :topbar => create_topbar_closed
  end
  
  get '/test_pusher' do
    Pusher['my_channel'].trigger('my_event', {:message => 'hello world'})
    haml :container_app, {}, :topbar => create_topbar_closed, :pusher_key => Pusher.key, :twitter_user_name => session['twitter_user_name']
  end

  # 無効なパスはすべてルートへ転送
  #get '/*' do
  #  DebugLog.info '/* called'
  #  redirect '/'
  #end
end
