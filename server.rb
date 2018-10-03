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

class Server < Sinatra::Base # rubocop:disable Metrics/ClassLength
  enable :sessions

  @@pusher_client = Pusher::Client.new( # rubocop:disable Style/ClassVars
    app_id: '610476',
    key: 'd99443f440ef4328b615',
    secret: '49ebba183891a1d3370d',
    cluster: 'us2',
    encrypted: true
  )

  configure :development do
    register Sinatra::Reloader
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

  # Methods for rspec testing
  def self.timer
    @@timer ||= 15 # rubocop:disable Style/ClassVars
  end

  def self.reset
    @@pending_games = {} # rubocop:disable Style/ClassVars
    @@games = {} # rubocop:disable Style/ClassVars
  end

  def self.change_timer
    @@timer = 0.1 # rubocop:disable Style/ClassVars
  end

  def self.inject_test_game
    @@games = GoFishGame.new(deck: TestDeck.new) # rubocop:disable Style/ClassVars
  end

  # Class Variables
  def self.games
    @@games ||= {} # rubocop:disable Style/ClassVars
  end

  def self.pending_games
    @@pending_games ||= {} # rubocop:disable Style/ClassVars
  end

  # Server methods
  def validate_user(user, pass)
    session[:user] = user.capitalize unless !user && !pass ## temporary until game implemented
  end

  def make_sure_game_exist(player_count)
    game = self.class.pending_games[player_count]
    self.class.pending_games[player_count] = create_game(player_count) if game.nil?
  end

  def create_game(player_count)
    game = GoFishGame.new
    Thread.start do
      sleep(self.class.timer)
      start_game(game, player_count)
      @@pusher_client.trigger(session[:game_id], 'refresh', { message: 'hello world' })
    end
    game
  end

  def join_a_game(player_count)
    make_sure_game_exist(player_count)
    game = self.class.pending_games[player_count]
    game.add_players(Player.new(name: session[:user]))
    session[:game_id] = game.game_id
    start_game(game, player_count) if game.players.count == player_count
  end

  def start_game(game, player_count)
    game.fill_game_with_bots(player_count) unless game.started
    self.class.pending_games.delete(player_count)
    self.class.games[game.game_id] = game
  end

  def find_game_by_id
    game_id = session[:game_id]
    game = self.class.pending_games.find { |_, pending_game| pending_game.game_id == game_id }
    game.nil? ? self.class.games[game_id] : game[1]
  end

  # Paths
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

  get('/play_setup') do
    slim(:play_setup)
  end

  post('/start') do
    join_a_game(params.fetch('player_count').to_i)
    redirect('/game')
  end

  get('/game') do
    game = find_game_by_id
    slim(:game, locals: { game: game, user: session[:user] })
  end

  post('/play') do
    return redirect('/game') if params['player'].nil? || params['rank'].nil?

    game = find_game_by_id
    player = params.fetch('player')
    rank = params.fetch('rank')
    game.play_round(player, rank)
    @@pusher_client.trigger(session[:game_id], 'refresh', {})
  end

  get('/quit') do
    game = find_game_by_id
    player = game.find_player(session[:user])
    player.toggle_autoplay
    game.auto_play
    puts player.auto
    puts game.winner
    redirect('/')
  end
end
