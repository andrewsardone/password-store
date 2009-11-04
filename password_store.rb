%w(rubygems sinatra dm-core dm-timestamps json).each { |lib| require lib }

mime :json, 'application/json'

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
  headers 'Content-Type' => 'application/json; charset=utf-8'
end

get '/' do
  
end