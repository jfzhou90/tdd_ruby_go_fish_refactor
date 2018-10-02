require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

RSpec.describe Server do
  let(:init) do
    Capybara::Session.new(:rack_test, Server.new)
    visit '/login'
    fill_in :username, with: 'User 1'
    fill_in :password, with: '123456'
    click_on 'Login'
    click_on 'Play'
  end

  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  it('correctly loads the page') do
    init
    expect(page).to have_content('How many Players?')
  end

  it('Play setup have a input button') do
    init
    expect(page).to have_css('.setup__input-player')
  end

  it('Play setup have a cancel button') do
    init
    click_on 'Cancel'
    expect(page).to have_current_path('/menu')
  end

  it('Play setup have a start button') do
    init
    click_on 'Start'
    expect(page).to have_current_path('/game')
  end
end
