require 'sinatra'
require 'redis'
require 'pry'
require 'json'

configure do
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri) 
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
  code = "Write your URL in the field and press enter to get it shortened!!<br>
          <br><form action='/' method='post'><input type='text' name='s'><input 
          type='submit'></form>"
  erb code
end

post '/' do
  original_url = params[:s]
  
  if redis.get(original_url)
    short_url = REDIS.get(original_url)
    code = "I already shortened this, here it is:<br><a href=
           '\/#{short_url}'>#{short_url}<\/a>"
  else
    short_url = rand(1000).to_s(16)
    REDIS.set(short_url, original_url)
    code = "Here it is your super short url:<br><a href='\/#{short_url}'>
           #{short_url}<\/a>"
  end
  erb code
end

get '/:short_url' do |short_url|
  redirect REDIS.get(short_url)
end
