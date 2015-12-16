require 'sinatra'
require 'sinatra/base'
require 'sinatra/jsonp'
require 'omniauth-twitter'
require 'twitter'
require 'json'

KEY = "kVdTORs1LCUtcJXDE5AXm1WW9"
SEC = "pPZ6uJPEyT1jWyi0N00yNa1c18w79zDBqht3rL2GvvkIR3vYBf"

use Rack::Session::Cookie
set :protection, :except => [:json_csrf]

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

get '/' do
  <<-HTML
  <h3>Hey! Hey! Welcome to Trento* public API</h3>
  <p><a href="/login">Sign in with Twitter</a></p>
  <p>#{params[:status]}</p>
  <p>(*) Trento is a demo assigment for <a href=\"//real-trends.com/?utm_source=trento&utm_campaing=assigments&utm_medium=referral\" target=\"_blank\">Real Trends</a></p>
  <p>Crafted by <a href=\"//danielnaranjo.info/?utm_source=trento&utm_campaing=assigments&utm_medium=referral\" target=\"_blank\">Daniel Naranjo</a></p>
  HTML

end

get '/auth/twitter/callback' do
	# Cross Domain Access
	response.headers['Access-Control-Allow-Origin'] = '*'

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

	#redirect to
	redirect to ('/tweetbyuser')
end

get '/tweetbyuser' do
	# Cross Domain Access
	response.headers['Access-Control-Allow-Origin'] = '*'

	if session[:admin] = nil
		redirect to ('/auth/failure?status=Not+logged')
	end

	#"You're in!"
	session[:admin] = true

	if params[:u] != ''
		user = params[:u]
	else 
		user = session[:username]
	end

	# Configure twitter client
	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = session[:token]
		config.access_token_secret = session[:secret]
	end

	# Map and JSONP result
	result = client.user_timeline(user)
	jsonp result.map(&:attrs)
end

post '/tweet' do
	
	if session[:admin] = nil
		redirect to ('/auth/failure?status=Not+logged')
	end

	#"You said '#{params[:message]}'"

	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = session[:token]
		config.access_token_secret = session[:secret]
	end

	#client.update('Tonight show: Playing with Twitter API + Sinatra on Heroku')
	client.update(params[:message])
	params[:message].to_json
end

get '/form' do
	if session[:admin] = nil
		redirect to ('/auth/failure?status=Not+logged')
	end
	<<-HTML
	<form action="/tweet" method="post">
	<input type="text" size="100" name="message" value="Play with Ruby and Sinatra while I listen to Frank singing My way https://www.youtube.com/watch?v=5AVOpNR2PIs">
	<input type="submit">
	</form>
	HTML
end

get '/private' do
	halt(401,'Not Authorized') unless admin?
	"Private party! Please check in lobby to get in."
end

get '/login' do
	if session[:admin] == nil
		redirect to ('/auth/twitter')
	else
		redirect to('/tweetbyuser')
	end
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

get '/gettingbyuser' do
	# Cross Domain Access
	response.headers['Access-Control-Allow-Origin'] = '*'

	# Configure twitter client
	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = params[:t]
		config.access_token_secret = params[:s]
	end

	# Map and JSONP result
	result = client.user_timeline(params[:u])
	jsonp result.map(&:attrs)
end

post '/send' do

	# Cross Domain Access
	response.headers['Access-Control-Allow-Origin'] = '*'

	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = params[:t]
		config.access_token_secret = params[:s]
	end

	client.update(params[:message])
	'Tweet was sent'.to_json
end

get '/delete' do
	# Cross Domain Access
	response.headers['Access-Control-Allow-Origin'] = '*'

	client = Twitter::REST::Client.new do |config|
		config.consumer_key = KEY
		config.consumer_secret = SEC
		config.access_token = params[:t]
		config.access_token_secret = params[:s]
	end

	client.destroy(params[:id])
end