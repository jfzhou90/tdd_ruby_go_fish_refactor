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
  let(:session1) { Capybara::Session.new(:rack_test, Server.new) }
  let(:session2) { Capybara::Session.new(:rack_test, Server.new) }

  let(:login) do
    Capybara::Session.new(:rack_test, Server.new)
    visit '/login'
    fill_in :username, with: 'User 1'
    fill_in :password, with: '123456'
    click_on 'Login'
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
end
