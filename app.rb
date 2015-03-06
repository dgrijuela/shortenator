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
  code = "Write your URL in the field and press enter to get it shortened!!<br>
          <br><form action='/' method='post'><input type='text' name='s'><input 
          type='submit'></form>"
  erb code
end

post '/' do
  shortify(params[:s])

  code = "Here it is your super short url:<br><a href='\/#{@short_url}'>
          #{@short_url}<\/a>"
  erb code
end


get '/:short_url' do |short_url|
  redirect REDIS.get(short_url)
end

private

def shortify(params)
  original_url = params
  unless original_url =~ /^http:\/\/.*$/ 
    original_url = "http://#{original_url}"
  end
  require 'securerandom'
  @short_url = SecureRandom.hex(2)
  REDIS.set(@short_url, original_url)
end
