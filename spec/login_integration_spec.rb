require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

RSpec.describe Server do
  let(:session1) { Capybara::Session.new(:rack_test, Server.new) }

  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  it('redirect to login page if not logged in') do
    session1.visit '/'
    expect(session1).to have_content('Username')
    expect(session1).to have_content('Password')
  end

  it('able to login and redirect to menu page') do
    session1.visit '/'
    session1.fill_in :username, with: 'User 1'
    session1.fill_in :password, with: '123456'
    session1.click_on 'Login'
    expect(session1.current_path).to eq('/menu')
  end
end
