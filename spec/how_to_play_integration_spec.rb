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
    click_on 'How to Play'
  end

  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  it('how to play have a title How to Play') do
    init
    expect(page).to have_content('How to Play')
  end

  it('how to play have a got it button and redirects to menu') do
    init
    click_on 'Got It'
    expect(page).to have_current_path('/menu')
  end
end
