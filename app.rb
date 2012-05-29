require './config/initializers/mongodb'
require './config/initializers/pusher'
require './models/user'
require './models/channel'
require 'dropbox_sdk'
require 'logger'
require 'pp'

DebugLog = Logger.new('debug.log')
DebugLog.info "debug.log created"

class MainApp < Sinatra::Base
  # enable _method hack
  set :method_override, true

  use Rack::Session::Cookie,
  #  :key => 'rack.session',
  #  :domain => 'localhost',
  #  :path => '/',
    :expire_after => 60*60*24*14, #2weeks
    :secret => 'uskfujino'

  #use OmniAuth::Strategies::Developer
  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
    provider :google_oauth2, ENV['GOOGLE_OAUTH2_KEY'], ENV['GOOGLE_OAUTH2_SECRET'], {:scope => 'userinfo.email,userinfo.profile,drive.file'}
    provider :dropbox, ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET']
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def project_name
      'Video Apps'
    end

    def topbar
      dropdown = haml :dropdown, {}, :nickname => find_nickname, :user_id => session['uid']
      signin_dropdown = haml :signin_dropdown
      haml :topbar, {}, :nickname => find_nickname, :dropdown => dropdown, :signin_dropdown => signin_dropdown
    end

    require './helpers/util'
  end

  def find_nickname
    user = find_user
    
    if user
      user.name
    elsif logged_in?
      session['user_name']
    else
      nil
    end
  end

  def find_user
    if logged_in? && User.exists?
      return User.where(login_id: session['uid']).first
    else
      nil
    end
  end

  def create_user(nickname)
    if logged_in?
      User.create(login_id: session['uid'], name: nickname)
    end
  end

  get '/' do
    if logged_in?
      haml :main, {}, :pusher_key => Pusher.key, :nickname => find_nickname
    else
      haml :welcome
    end
  end

  # Twitter認証成功時に呼ばれる
  get '/auth/twitter/callback' do
    auth = request.env['omniauth.auth']
    session['user_name'] = auth['info']['nickname']
    session['uid'] = auth['provider'] + auth['uid']
    redirect '/'
  end

  # Googlel-OAuth2認証成功時に呼ばれる
  get '/auth/google_oauth2/callback' do
    auth = request.env['omniauth.auth']
    #DebugLog.info auth.to_yaml
    session['user_name'] = auth['info']['name']
    session['uid'] = auth['provider'] + auth['uid']
    redirect '/'
  end

  # Dropbox認証成功時に呼ばれる
  get '/auth/dropbox/callback' do
    auth = request.env['omniauth.auth']
    session['user_name'] = auth['info']['name']
    session['uid'] = auth['provider'] + auth['uid'].to_s
    dropbox_session = DropboxSession.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
    dropbox_session.get_request_token
    dropbox_session.set_access_token(auth[:credentials][:token], auth[:credentials][:secret])
    session[:dropbox_session] = dropbox_session.serialize
    redirect '/dropbox'
  end

  # Pusher認証処理
  post '/pusher/auth' do
    puts '/pusher/auth called'

    redirect '/' unless logged_in?

    puts params[:channel_name]
    puts params[:socket_id]

    ret = Pusher[params[:channel_name]].authenticate(params[:socket_id]).to_json

    puts ret

    ret
  end

  def logout
    session['user_name'] = nil
    session['uid'] = nil
    session[:dropbox_session] = nil
  end

  def logged_in?
    session['user_name'] != nil && session['uid'] != nil
  end

  def dropbox_authorized?
    if !logged_in? || session[:dropbox_session] == nil
      false
    else
      DropboxSession.deserialize(session[:dropbox_session]).authorized?
    end
  end

  get '/logout' do
    logout
    redirect '/'
  end

  get '/users/*/edit' do
    if logged_in?
      haml :edit_account, {}, :user_id => session['uid'], :nickname => find_nickname
    else
      redirect '/'
    end
  end

  put '/users/:user_id' do
    user_id = params[:user_id]
    redirect_url = "/users/#{user_id}/edit"

    if !logged_in? || user_id != session['uid']
      redirect redirect_url
    end

    nickname = request['put']['nickname']

    if !nickname
      redirect redirect_url
    end

    user = find_user

    if user
      user.name = nickname
    else
      user = create_user(nickname)
    end

    user.save

    redirect redirect_url
  end

  def create_camera(channel)
    camera = haml :camera, {}, :pusher_key => Pusher.key, :channel => channel
    video = haml :video, {}, :pusher_key => Pusher.key, :channels => find_channels, :uid => session['uid']
    haml :play_camera, {}, :camera => camera, :video => video, :channel => channel
  end
  
  get '/camera' do
    puts 'get /camera called'
    create_camera nil
  end

  post '/camera' do
    puts 'post /camera called'
    redirect '/camera' unless logged_in?

    channel_name = params[:post][:channel_name]

    if channel_name == '' || channel_name == nil
      redirect '/camera'
    end

    create_camera Channel.create(name: channel_name, owner_id: session['uid'], owner_name: session['user_name'])
  end

  def find_channels
    Channel.all if Channel.exists?
  end
  
  def find_channel channel_id
    Channel.where(id: channel_id).first if Channel.exists?
  end

  get '/channel' do
    haml :channel, {}, :pusher_key => Pusher.key, :channels => find_channels
  end

  # 無効なパスはすべてルートへ転送
  get '/*' do
    puts '#Unknown url get : ' + request.url
    redirect '/'
  end
end
