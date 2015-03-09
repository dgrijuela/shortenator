require 'sinatra'
require 'redis'
require 'json'

configure do
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri) 
  REDIS_URLS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, db: 1) # List
  REDIS_COUNTER = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, db: 2) # Shorted set
  ROOT_URL = "https://shortenator.herokuapp.com"
end

get '/new.json' do
  shortify(params[:url])
  content_type :json
  { "short_url" => "#{ROOT_URL}/#{@short_url}" }
end

get '/' do
  get_ranking
  erb 'index.html'.to_sym
end

post '/' do
  shortify(params[:s])
  get_ranking
  erb 'show.html'.to_sym
end

get '/:short_url' do |short_url|
  count(short_url)
  redirect REDIS_URLS.get(short_url)
end

private

def shortify(params)
  original_url = params
  unless original_url =~ /^http:\/\/.*$|^https:\/\/.*$/ 
    original_url = "http://#{original_url}"
  end
  require 'securerandom'
  @short_url = SecureRandom.hex(2)
  REDIS_URLS.set(@short_url, original_url)
end

def count(short_url)
  if REDIS_COUNTER.zscore 'counter', short_url
    REDIS_COUNTER.zincrby 'counter', 1, short_url
  else
    REDIS_COUNTER.zadd 'counter', 1, short_url
  end
end

def get_ranking
  @ranking = REDIS_COUNTER.zrange 'counter', 0, -1, { with_scores: true }
  @ranking.each do |r|
    short_url = r.first
    r.push REDIS_URLS.get(short_url)
  end

end
