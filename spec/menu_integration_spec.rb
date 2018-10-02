require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

RSpec.describe Server do
  let(:login) do
    Capybara::Session.new(:rack_test, Server.new)
    visit '/login'
    fill_in :username, with: 'User 1'
    fill_in :password, with: '123456'
    click_on 'Login'
  end

  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  it('menu page have play button and clickable') do
    login
    click_on 'Play'
    expect(page.current_path).to eq('/play_setup')
  end

  it('menu page have how to play button and clickable') do
    login
    click_on 'How to Play'
    expect(page.current_path).to eq('/how_to_play')
  end

  it('menu page have log out button and clickable') do
    login
    click_on 'Log Out'
    expect(page.current_path).to eq('/login')
  end
end
