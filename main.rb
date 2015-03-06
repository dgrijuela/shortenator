require 'sinatra'

url_relation = {}

get '/' do
  code = "Write your URL in the field and press enter to get it shortened!!<br>
          <br><form action='/' method='post'><input type='text' name='s'><input 
          type='submit'></form>"
  erb code
end

post '/' do
  original_url = params[:s]
  
  if url_relation.invert[original_url]
    short_url = url_relation.invert[original_url]
    code = "I already shortened this, here it is:<br><a href=
           '\/#{short_url}'>#{short_url}<\/a>"
  else
    short_url = rand(1000).to_s(16)
    url_relation[short_url] = original_url
    code = "Here it is your super short url:<br><a href='\/#{short_url}'>
           #{short_url}<\/a>"
  end
  erb code
end

get '/:short_url' do |short_url|
  redirect url_relation[short_url]
end
