require 'sinatra'
require 'sinatra/reloader'
also_reload('lib/**/*.rb')
also_reload('views/**/*.slim')
require 'sprockets'
require 'sass'
require 'slim'
require_relative 'lib/go_fish_game'
require_relative 'lib/player'
require 'pry'
require 'pusher'

class Server < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
    @@pusher_client = Pusher::Client.new( # rubocop:disable Style/ClassVars
      app_id: '610476',
      key: 'd99443f440ef4328b615',
      secret: '49ebba183891a1d3370d',
      cluster: 'us2',
      encrypted: true
    )
  end

  before '/*' do
    pass if request.path =~ /assets/
    redirect('/login') if session['user'].nil? && request.path_info != '/login'
  end

  # Start Assets
  set :environment, Sprockets::Environment.new
  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/images'
  environment.append_path 'assets/fonts'
  environment.append_path 'assets/javascripts'
  environment.css_compressor = :scss

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end
  # End Assets

  def self.games
    @@games ||= {} # rubocop:disable Style/ClassVars
  end

  def self.pending_games
    @@pending_game ||= {} # rubocop:disable Style/ClassVars
  end

  def self.reset
    @@pending_games = {} # rubocop:disable Style/ClassVars
    @@games = {} # rubocop:disable Style/ClassVars
  end

  def self.inject_test_deck
    @@game = GoFishGame.new(deck: TestDeck.new) # rubocop:disable Style/ClassVars
  end

  def validate_user(user, pass)
    session[:user] = user.capitalize unless !user && !pass ## temporary until game implemented
  end

  get '/' do
    redirect('/menu')
  end

  get '/login' do
    slim(:login)
  end

  post '/login' do
    username = params.fetch('username')
    password = params.fetch('password')
    validate_user(username, password) ? redirect('/menu') : redirect('/login')
  end

  get '/logout' do
    session.clear
    redirect('/login')
  end

  get '/menu' do
    slim(:menu, locals: { user: session[:user] })
  end

  get('/how_to_play') do
    slim(:how_to_play)
  end

  get('/quick_play_setup') do
    slim(:quick_play_setup)
  end

  get('/play_setup') do
    slim(:play_setup)
  end
end
