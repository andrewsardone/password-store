require 'password_store.rb'

set :environment, :production
set :run, false

run Sinatra::Application
