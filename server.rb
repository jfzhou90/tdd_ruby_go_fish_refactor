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
    redirect('/login') if session['username'].nil? && request.path_info != '/login'
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

  def self.game
    @@game ||= GoFishGame.new # rubocop:disable Style/ClassVars
  end

  def validate_user(user, pass)
    session[:username] = user.capitalize unless !user && !pass ## temporary until game implemented
  end

  get '/' do
    slim(:menu, locals: { user: session[:username] })
  end

  get '/login' do
    slim(:login)
  end

  get '/logout' do
    session.clear
    slim(:login)
  end

  post '/login' do
    username = params.fetch('username')
    password = params.fetch('password')
    validate_user(username, password) ? redirect('/') : redirect('/login')
  end

  get('/how_to_play') do
    slim(:how_to_play)
  end

  get('/setup') do
    slim(:game_setup)
  end

  post('/join') do
    Player.new(name: session[:username])
    self.class.game.add_players(Player.new(name: session[:username]))
    self.class.game.start if self.class.game.players.count == 2
    redirect('/game')
  end

  get('/game') do
    slim(:game, locals: { game: self.class.game, user: session[:username] })
  end

  post('/play') do
    return redirect('/game') if params['player'].nil? || params['rank'].nil?

    player = params.fetch('player')
    rank = params.fetch('rank')
    self.class.game.play_round(player, rank)
    @@pusher_client.trigger('my-channel', 'my-event', { message: 'hello world' })
    redirect('/game')
  end

  def self.reset
    @@game = GoFishGame.new # rubocop:disable Style/ClassVars
  end

  def self.inject_test_deck
    @@game = GoFishGame.new(deck: TestDeck.new) # rubocop:disable Style/ClassVars
  end
end
