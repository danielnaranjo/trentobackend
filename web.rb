#web.rb

require 'sinatra'
require 'sinatra/jsonp'
require 'omniauth-twitter'
require 'twitter'
require 'json'

KEY = "kVdTORs1LCUtcJXDE5AXm1WW9"
SEC = "pPZ6uJPEyT1jWyi0N00yNa1c18w79zDBqht3rL2GvvkIR3vYBf"

use Rack::Session::Cookie
use OmniAuth::Builder do
	provider :twitter, KEY, SEC
end

configure do
	enable :sessions
end

helpers do
	def admin?
		session[:admin]
	end
end

#set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  <<-HTML
  <h3>Hey! Hey! Welcome to Trento* public API</h3>
  <p><a href="/login">Login with Twitter</a></p>
  <p>#{params[:status]}</p>
  <p>(*) Trento is a demo assigment for <a href=\"//real-trends.com/?utm_source=trento&utm_campaing=assigments&utm_medium=referral\" target=\"_blank\">Real Trends</a></p>
  <p>Crafted by <a href=\"//danielnaranjo.info/?utm_source=trento&utm_campaing=assigments&utm_medium=referral\" target=\"_blank\">Daniel Naranjo</a></p>
  HTML

  #render
  #erb :index, :layout => :site
end

get '/auth/twitter/callback' do
	#env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorized')
	
	#"You're in!"
	session[:admin] = true

	# varibles
	session[:uid] = env['omniauth.auth']['uid']
	session[:username] = env['omniauth.auth']['info']['name']
	session[:nickname] = env['omniauth.auth']['info']['nickname']
	session[:location] = env['omniauth.auth']['info']['location']
	session[:imagen] = env['omniauth.auth']['info']['imagen']
	session[:description] = env['omniauth.auth']['info']['description']
	
	# Token
	session[:token] = env['omniauth.auth']['credentials']['token']
	session[:secret] = env['omniauth.auth']['credentials']['secret']

	# HTML basic
	# <<-HTML
	# 	<h3>#{session[:username]} (<a href="/logout?nickname=#{session[:nickname]}">Get out here!</a>)</h3>
	# 	<p>#{session[:description]}</p>
	# 	<p>#{session[:location]}</p>
	# 	<ul>
	# 		<li>
	# 			<a href="/tweetbyuser?u=#{session[:nickname]}&t=#{session[:token]}&s=#{session[:secret]}">Go to Tweets</a>
	# 		</li>
	# 		<li>
	# 			<a href="/tweet?u=#{session[:nickname]}&t=#{session[:token]}&s=#{session[:secret]}&text=Playing+with+Twitter+API+Sinatra+on+Heroku+by+@NaranjoDaniel">Test Me :)</a>
	# 		</li>
	# 	</ul>
	# HTML

	#erb
	#erb :user, :layout => :site

	# JSON response
	#env['omniauth.auth'].to_json

	#redirect to
	redirect to ('/tweetbyuser')
end

get '/tweetbyuser' do
	#"You're in!"
	session[:admin] = true

	# Configure twitter client
	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = session[:token]
		config.access_token_secret = session[:secret]
	end

	# Map and JSONP result
	result = client.user_timeline(session[:username])
    jsonp result.map(&:attrs)
end

post '/tweet' do
	request.body.rewind
	data = JSON.parse request.body.read

	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = params[:t]
		config.access_token_secret = params[:s]
	end

	#client.update('Tonight show: Playing with Twitter API + Sinatra on Heroku')
	client.update(data['text'])
	text.to_json

	#redirect to('/?status=Thanks+for+Playing')
	#session[:admin] = nil
end

get '/private' do
	halt(401,'Not Authorized') unless admin?
	"Private party! Please check in lobby to get in."
end

get '/login' do
	redirect to ('/auth/twitter')
end

get '/auth/failure' do
	params[:message]
	redirect to('/?status='+params[:message])
end

get '/logout' do
	session[:admin] = nil
	session[:uid] = nil
	session[:username] = nil
	session[:nickname] = nil
	session[:location] = nil
	session[:imagen] = nil
	session[:description] = nil
	session[:token] = nil
	session[:secret] = nil
	redirect to('/?status=You+are+logout+successfully')
end