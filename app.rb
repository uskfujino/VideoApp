require './config/initializers/mongodb'
#require './config/initializers/pusher'
require './models/user'
require './models/tweet'
require './models/session'
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
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def project_name
      'Sandbox Apps'
    end

    def topbar
      dropdown = haml :dropdown, {}, :nickname => find_nickname, :user_id => session['twitter_user_id']
      haml :topbar, {}, :nickname => find_nickname, :dropdown => dropdown
    end

    require './helpers/util'
  end

  def find_nickname
    user = find_user
    
    if user
      user.name
    elsif logged_in?
      session['twitter_user_name']
    else
      nil
    end
  end

  def find_user
    if logged_in? && User.exists?
      return User.where(login_id: session['twitter_user_id']).first
    else
      nil
    end
  end

  def create_user(nickname)
    if logged_in?
      User.create(login_id: session['twitter_user_id'], name: nickname)
    end
  end

  def find_tweets
    if !Tweet.exists?
      nil
    elsif logged_in?
      Tweet.where(user_id: session['twitter_user_id']).all
    else
      Tweet.all
    end
  end

  def find_tweet(id)
    if !Tweet.exists?
      return nil
    end

    Tweet.find(id)
  end

  def my_tweet?(tweet)
    if !logged_in? || tweet == nil
      false
    else
      tweet.user_id == session['twitter_user_id']
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
    session['twitter_user_name'] = auth['info']['nickname']
    session['twitter_user_id'] = auth['uid']
    redirect '/'
  end

  def logout
    session['twitter_user_name'] = nil
    session['twitter_user_id'] = nil
  end

  def logged_in?
    session['twitter_user_name'] != nil && session['twitter_user_id'] != nil
  end

  get '/logout' do
    logout
    redirect '/'
  end

  get '/users/*/edit' do
    if logged_in?
      haml :edit_account, {}, :user_id => session['twitter_user_id'], :nickname => find_nickname
    else
      redirect '/'
    end
  end

  put '/users/:user_id' do
    user_id = params[:user_id]
    redirect_url = "/users/#{user_id}/edit"

    if !logged_in? || user_id != session['twitter_user_id']
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
    if !logged_in?
      redirect '/'
    end

    tweet = params[:post][:tweet]

    if tweet == '' || tweet == nil
      redirect '/'
    end

    Tweet.create(user_id: session['twitter_user_id'], user_name: session['twitter_user_name'], time: Time.now, message: tweet)

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
    haml :play_camera
  end

  # 無効なパスはすべてルートへ転送
  get '/*' do
    puts '#Unknown url get'
    redirect '/'
  end
end
