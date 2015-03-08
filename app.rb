require 'sinatra'
require 'redis'
require 'json'

configure do
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri) 
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  ROOT_URL = "https://shortenator.herokuapp.com"
end

get '/new.json' do
  shortify(params[:url])
  content_type :json
  { "short_url" => "#{ROOT_URL}/#{@short_url}" }
end

get '/' do
  erb 'index.html'.to_sym
end

post '/' do
  shortify(params[:s])
  erb 'show.html'.to_sym
end


get '/:short_url' do |short_url|
  redirect REDIS.get(short_url)
end

private

def shortify(params)
  original_url = params
  unless original_url =~ /^http:\/\/.*$|^https:\/\/.*$/ 
    original_url = "http://#{original_url}"
  end
  require 'securerandom'
  @short_url = SecureRandom.hex(2)
  REDIS.set(@short_url, original_url)
end
