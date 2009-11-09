%w(rubygems sinatra dm-core dm-serializer dm-timestamps haml json).each { |lib| require lib }

configure :development do 
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

# DataMapper doesn't do Single Table Inheritance (STI) like ActiveRecord
# does. Instead, create a module with class evaluated property declarations
# and include it within your model classes.
# http://wiki.github.com/sam/dm-core/simulating-polymorphic-associations
module Account
  def self.included(other)
    other.class_eval <<-EOS
      property :id,          Serial
      property :username,    String
      property :password,    String
      property :url,         String
      property :created_at,  DateTime
      property :updated_at,  DateTime
      
      has n, :projects, :through => Resource
    EOS
  end
end

class WebLogin
  include DataMapper::Resource
  include Account
  
end

class Database
  include DataMapper::Resource
  include Account
  
  property :port, Integer
  property :dbname, String
  property :sid, Integer
  
  belongs_to :database_type
end

class DatabaseType
  include DataMapper::Resource
  
  property :id,   Serial
  property :type, String
  
  has n, :databases
end

class Server
  include DataMapper::Resource
  include Account
end

class Project
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String
  
  has n, :web_logins, :through => Resource
  has n, :databases, :through => Resource
  has n, :servers, :through => Resource
end

configure :development do
  # Create or upgrade all tables at once, like magic
  DataMapper.auto_upgrade!
end

# set utf-8 for outgoing
before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end

helpers do
  def json(body)
    content_type 'application/json; charset=utf-8'
    params[:callback] ? "#{params[:callback]}(#{body});" : body.to_json
  end
end

get '/' do
  @title = 'Password Store'
  haml :index
end

get '/weblogins' do
  @title = 'Web Logins'
  @web_logins = WebLogin.all :order => [:created_at.desc]
  haml :list
end

get '/weblogins.json' do
  @web_logins = WebLogin.all :order => [:created_at.desc]
  json @web_logins
end

post '/weblogins/create.json' do
  if params[:web_login].nil?
    status 406
    return
  end
  @web_login = WebLogin.new params[:web_login]
  if @web_login.save
    status 201
    json @web_login
  else
    status 500
  end
end

delete '/weblogins/:id' do
  WebLogin.get(params[:id]).destroy
end

__END__

@@ layout
!!! 1.1
%html
  %head
    %title= @title
  %body
    = yield

@@ index
%h1= @title

@@ list
%h1= @title
- @web_logins.each do |wl|
  - wl.attributes.each do |k,v|
    %p
      %b= k
      = v
  %hr/
