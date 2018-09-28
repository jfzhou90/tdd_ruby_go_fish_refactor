require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

def play_round(session, rank)
  session.choose 'User 2'
  session.choose(rank, match: :first)
  session.click_on 'Play'
end

RSpec.describe Server do
  let(:login) do
    Capybara::Session.new(:rack_test, Server.new)
    visit '/login'
    fill_in :username, with: 'User 1'
    fill_in :password, with: '123456'
    click_on 'Login'
  end

  let(:multi_session) do
    session1 = Capybara::Session.new(:rack_test, Server.new)
    session2 = Capybara::Session.new(:rack_test, Server.new)
    [ session1, session2 ].each_with_index do |session, index|
      user_name = "User #{index + 1}"
      session.visit '/login'
      session.fill_in :username, with: user_name
      session.click_on 'Login'
      session.click_on 'Play'
      session.click_on 'Start'
    end
    session1.driver.refresh
    [ session1, session2 ]
  end

  include Capybara::DSL
  before do
    Capybara.app = Server.new
    Server.inject_test_deck
  end

  after do
    Server.reset
  end

  it('is possible to login into the game') do
    login
    expect(page).to have_content('Play')
    expect(page).to have_content('How to Play')
  end

  it('able to read the instruction') do
    login
    click_on 'How to Play'
    expect(page).to have_content('Got It')
  end

  it('able to logout after login') do
    login
    click_on 'Log Out'
    expect(page).to have_content('Username')
  end

  it('is possible to start a game') do
    login
    click_on 'Play'
    fill_in :player_count, with: 5
    click_on 'Start'
    expect(page).to have_content('User')
  end

  it 'allows users to have personalize main page.' do
    session1 = Capybara::Session.new(:rack_test, Server.new)
    session2 = Capybara::Session.new(:rack_test, Server.new)
    [ session1, session2 ].each_with_index do |session, index|
      user_name = "User #{index + 1}"
      session.visit '/login'
      session.fill_in :username, with: user_name
      session.click_on 'Login'
      expect(session).to have_css('h1', text: user_name)
    end
    expect(session1).to have_content('User 1')
    expect(session2).to have_content('User 2')
  end

  it 'allows multiple players to join game' do
    session1, session2 = multi_session
    expect(session2).to have_content('User 1')
    expect(session1).to have_content('User 2')
  end

  it 'checks if players have 7 cards each for a 2 player game' do
    session1, = multi_session
    expect(session1).to have_css('.fake__card--card', count: 7)
    expect(session1).to have_css('.player__card--big', count: 7)
  end

  it 'only current player have the play button' do
    session1, session2 = multi_session
    expect(session1).to have_css('.play__round')
    expect(session2).to_not have_css('.play__round')
  end

  it 'current player can play a round, make a book, and earn a point' do
    session1, session2 = multi_session
    play_round(session1, 'Ace')
    session2.driver.refresh
    expect(session2).to have_css('.player__card--big', count: 5)
    expect(session1).to have_css('.player__card--big', count: 5)
    expect(session1).to have_css('.current__user--points', text: 1)
    expect(session1).to have_content("User 1's Turn")
  end

  it 'goes to next user if player did not fish anything' do
    session1, session2 = multi_session
    play_round(session1, '3')
    Server.game.deck.shuffle_test
    play_round(session1, '3')
    session2.driver.refresh
    expect(session1 && session2).to have_content("User 2's Turn")
    expect(session1).to have_css('.player__card--big', count: 9)
    expect(session2).to have_css('.play__round')
    expect(session1).to_not have_css('.play__round')
  end
end
