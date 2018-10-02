require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

RSpec.describe Server do
  let(:session1) { Capybara::Session.new(:rack_test, Server.new) }
  let(:session2) { Capybara::Session.new(:rack_test, Server.new) }

  let(:login) do
    Capybara::Session.new(:rack_test, Server.new)
    visit '/login'
    fill_in :username, with: 'User 1'
    click_on 'Login'
    click_on 'Play'
    fill_in :player_count, with: 5
    click_on 'Start'
  end

  let(:multi_session) do
    [ session1, session2 ].each_with_index do |session, index|
      user_name = "User #{index + 1}"
      session.visit '/login'
      session.fill_in :username, with: user_name
      session.click_on 'Login'
      session.click_on 'Play'
      session.click_on 'Start'
    end
    [ session1, session2 ]
  end

  include Capybara::DSL
  before do
    Server.reset
    Capybara.app = Server.new
  end

  describe('#join_a_game') do
    it('allows user to join a game and waiting for game to be started') do
      login
      expect(Server.pending_games[5].players.count).to be(1)
    end

    it('allows 2 user to join a game, and starts the game if possible') do
      multi_session
      expect(Server.pending_games[2]).to be(nil)
      expect(Server.games.count).to be(1)
    end
  end

  describe('#start a game of bots') do
    before { Server.change_timer }
    it('plays a game of bots with one player') do
      login
      sleep(0.3)
      game_id = Server.games.keys[0]
      expect(Server.games[game_id].players.count).to be(5)
      expect(Server.games[game_id].players.count(&:auto)).to be(4)
    end
  end
end
