ID.me Sample Ruby Web App
This is a sample OpenID Connect seed Ruby Web App built with Sinatra 

Installation and Setup
In order to run the example you need to have ruby and rubygems installed.

First, install the required gems

gem install bundler
bundle install
Next, configure your oauth settings in app.rb

# app.rb
client_id     = "YOUR_CLIENT_ID"
client_secret = "YOUR_CLIENT_SECRET"
scope         = "YOUR_SCOPE_VALUE"
Start the server and view the app at http://localhost:4567

ruby app.rb