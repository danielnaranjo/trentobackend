#web.rb

require 'sinatra'
require 'omniauth-twitter'
require 'twitter'
require 'json'

use Rack::Session::Cookie
use OmniAuth::Builder do
	provider :twitter, "kVdTORs1LCUtcJXDE5AXm1WW9", "pPZ6uJPEyT1jWyi0N00yNa1c18w79zDBqht3rL2GvvkIR3vYBf"
end

configure do
	enable :sessions
end

# client = Twitter::REST:Client.new do |config|
	# config.consumer_key = "kVdTORs1LCUtcJXDE5AXm1WW9"
	# config.consumer_secret = "pPZ6uJPEyT1jWyi0N00yNa1c18w79zDBqht3rL2GvvkIR3vYBf"
# 	config.access_token = "110495478-qnrKkkokaooS4xZhfjwI3m2xL9Mj5gF6xKFW5Lsh"
# 	config.access_token_secret = "IRyN7oP4lPMQzv7Glhqc5J1dDM6p578gyJ3XBjalX17fG"
# end

helpers do
	def admin?
		session[:admin]
	end
end

get '/' do
  <<-HTML
  <h3>Hey! Hey! Welcome to Trento* public API</h3>
  <p><a href="/login">Login with Twitter</a></p>
  <p>#{params[:error]}#{params[:status]}</p>
  <p>(*) Trento is a demo assigment for <a href=\"//real-trends.com/?utm_source=trento&utm_campaing=assigments&utm_medium=referral\" target=\"_blank\">Real Trends</a></p>
  <p>Crafted by <a href=\"//danielnaranjo.info/?utm_source=trento&utm_campaing=assigments&utm_medium=referral\" target=\"_blank\">Daniel Naranjo</a></p>
  HTML
end

get '/private' do
	halt(401,'Not Authorized') unless admin?
	"Private party! Please check in lobby to get in."
end

get '/login' do
	#session[:admin] = true
	#"You're Logged"
	redirect to ('/auth/twitter')
end

get '/auth/twitter/callback' do
	t = params[:oauth_token]
	v = params[:oauth_verifier]
	#env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorized')
	#"You're in!"
	session[:admin] = true
	session[:uid] = env['omniauth.auth']['uid']
	session[:username] = env['omniauth.auth']['info']['name']
	session[:nickname] = env['omniauth.auth']['info']['nickname']
	session[:location] = env['omniauth.auth']['info']['location']
	session[:imagen] = env['omniauth.auth']['info']['imagen']
	session[:description] = env['omniauth.auth']['info']['description']
	token = env['omniauth.auth']['credentials']['token']
	secret = env['omniauth.auth']['credentials']['secret']

	<<-HTML
	<h3>#{session[:username]}</h3>
	<p><a href="/logout?nickname=#{session[:nickname]}">Get out here!</a></p>
	<p>#{session[:description]}</p>
	<p>#{session[:location]}</p>
	<ul>
		<li>#{token}</li>
		<li>#{secret}</li>
	</ul>
	<p>
		<a href="/tweetbyuser?u=#{session[:nickname]}&t=#{token}&v=#{secret}">Go to Tweets</a>
	</p>
	HTML

	#env['omniauth.auth'].to_json
end

get '/auth/failure' do
	params[:message]
	redirect to('/?error='+params[:message])
end

get '/logout' do
	session[:admin] = nil
	redirect to('/?status=byebye')
	<<-HTML
		<h3>You're Out!</h3>
	HTML
end

get '/tweet/:text' do
	text = params[:text]

	client = Twitter::REST::Client.new do |config|
		config.consumer_key = "kVdTORs1LCUtcJXDE5AXm1WW9"
		config.consumer_secret = "pPZ6uJPEyT1jWyi0N00yNa1c18w79zDBqht3rL2GvvkIR3vYBf"
		config.access_token = "110495478-qnrKkkokaooS4xZhfjwI3m2xL9Mj5gF6xKFW5Lsh"
		config.access_token_secret = "IRyN7oP4lPMQzv7Glhqc5J1dDM6p578gyJ3XBjalX17fG"
	end
	#client.update('Tonight show: Playing with Twitter API + Sinatra on Heroku')
	client.update(text)
	return status 404 if text.nil?
	text.to_json
	#redirect to('/tweetbyuser?u=naranjodaniel')
end

get '/tweetbyuser' do
	client = Twitter::REST::Client.new do |config|
		config.consumer_key = "kVdTORs1LCUtcJXDE5AXm1WW9"
		config.consumer_secret = "pPZ6uJPEyT1jWyi0N00yNa1c18w79zDBqht3rL2GvvkIR3vYBf"
		config.access_token = "110495478-qnrKkkokaooS4xZhfjwI3m2xL9Mj5gF6xKFW5Lsh"
		config.access_token_secret = "IRyN7oP4lPMQzv7Glhqc5J1dDM6p578gyJ3XBjalX17fG"
	end
	client.user('naranjodaniel').to_json
end
