require('sinatra')
require('sinatra/reloader')
also_reload('lib/**/*.rb')

get('/') do
  erb(:login)
end

post('/menu') do
  sleep(0.2)
  username = params.fetch('username')
  password = params.fetch('password')
  validate_user(username, password) ? erb(:menu) : erb(:login)
end

get('/menu') do
  erb(:menu)
end

get('/play') do
  erb(:play)
end

get('/how_to_play') do
  erb(:how_to_play)
end

get('/logout') do
  erb(:login)
end

def validate_user(user, pass)
  true unless !user && !pass ## temporary until game implemented
end
