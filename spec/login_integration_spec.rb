require('capybara/rspec')
require('./app')
Capybara.app = Sinatra::Application
set(:show_exceptions, false)

describe('the login path', { type: :feature }) do
  it('user can login.') do
    visit('/')
    fill_in('username', with: 'admin')
    fill_in('password', with: 'password')
    click_button('Login')
    expect(page).to have_content('Play').and have_content('How to Play').and have_content('Log Out')
  end
end
