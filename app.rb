require './config/initializers/mongodb'
require './config/initializers/pusher'
require './models/user'
require './models/tweet'
require './models/session'
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
      'Sandbox Apps'
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

  def find_tweets
    if !Tweet.exists?
      nil
    elsif logged_in?
      Tweet.where(user_id: session['uid']).all
    else
      Tweet.all
    end
  end

  def find_tweet(id)
    return nil unless Tweet.exists?

    Tweet.find(id)
  end

  def my_tweet?(tweet)
    if !logged_in? || tweet == nil
      false
    else
      tweet.user_id == session['uid']
    end
  end

  def delete_tweet(id)
    tweet = find_tweet(id)

    if my_tweet? tweet
      tweet.delete
    end
  end

  get '/' do
    tweet_page = haml :tweets, {}, :tweets => find_tweets

    if logged_in?
      haml :main, {}, :pusher_key => Pusher.key, :tweet_page => tweet_page, :nickname => find_nickname
    else
      haml :welcome, {}, :tweet_page => tweet_page
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
    #DebugLog.info auth.to_yaml
    #DebugLog.info params.to_yaml
    session['user_name'] = auth['info']['name']
    session['uid'] = auth['provider'] + auth['uid'].to_s
    dropbox_session = DropboxSession.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
    dropbox_session.get_request_token
    dropbox_session.set_access_token(auth[:credentials][:token], auth[:credentials][:secret])
    #dropbox_session.authorize(params)
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
=begin
    puts params['socket_id'] + ':' + params['channel_name']

    pusher_signature = HMAC::SHA256.hexdigest(Pusher.secret, params['socket_id'] + ':' + params['channel_name'])

    puts pusher_signature

    auth = Pusher.key + ':' + pusher_signature

    puts auth

    {auth: auth}.to_json
=end
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
    #logged_in? && DropboxSession.deserialize(session).authorized?
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

  post '/tweet' do
    redirect '/' unless logged_in?

    tweet = params[:post][:tweet]

    if tweet == '' || tweet == nil
      redirect '/'
    end

    Tweet.create(user_id: session['uid'], user_name: session['user_name'], time: Time.now, message: tweet)

    redirect '/'
  end

  delete '/tweet/:id' do
    puts 'delete /tweet/:id called'
    delete_tweet(params[:id])
    redirect '/'
  end

  get '/test_pusher' do
    Pusher['my_channel'].trigger('my_event', {:message => 'hello world'})
    haml :main, {}, :pusher_key => Pusher.key, :tweets => find_tweets, :nickname => find_nickname
  end

  get '/canvas' do
    haml :play_canvas
  end

  get '/camera' do
    haml :play_camera, {}, :pusher_key => Pusher.key, :channel_id => nil
  end

  post '/camera' do
    redirect '/camera' unless logged_in?

    channel_name = params[:post][:channel_name]

    if channel_name == '' || channel_name == nil
      redirect '/camera'
    end

    channel = Channel.create(name: channel_name)

    haml :play_camera, {}, :pusher_key => Pusher.key, :channel_id => channel.id
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

  get '/drive' do
    haml :play_drive
  end

  DROPBOX_ACCESS_TYPE = :app_folder

  get '/dropbox' do
    redirect '/' unless dropbox_authorized?
    dropbox_session = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dropbox_session, DROPBOX_ACCESS_TYPE)
    if params[:query]
      search_result = client.search('/', params[:query], 1000)
    else
      search_result = client.search('/', 'txt', 1000)
    end
    myfolder = haml :myfolder, {}, :search_result => search_result
    haml :play_dropbox, {}, :myfolder => myfolder
  end

  post '/dropbox/upload' do
    redirect '/dropbox' unless dropbox_authorized?
    dropbox_session = DropboxSession.deserialize(session[:dropbox_session])

    # ACCESS_TYPE should be ':dropbox' or ':app_folder' as configured for your app
    client = DropboxClient.new(dropbox_session, DROPBOX_ACCESS_TYPE)
    puts "linked account:", client.account_info().inspect

    file = open('./public/working-draft.txt')
    target_file = params[:post][:filename]
    if target_file == nil || target_file == ''
      redirect '/dropbox'
    end
    target_path = '/' + target_file
    response = client.put_file(target_path, file)
    puts "uploaded:", response.inspect
    file_metadata = client.metadata(target_path)
    puts "metadata:", file_metadata.inspect

    redirect '/dropbox'
  end

  # 無効なパスはすべてルートへ転送
  get '/*' do
    puts '#Unknown url get'
    redirect '/'
  end
end
