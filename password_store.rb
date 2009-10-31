%w(rubygems sinatra dm-core dm-timestamps).each { |lib| require lib }

configure :development do 
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

# DataMapper doesn't do Single Table Inheritance (STI) like ActiveRecord
# does. Instead, create a module with class evaluated property declarations
# and include it within your model classes.
module Account
  def self.included(other)
    other.class_eval <<-EOS
      property :id,          Serial
      property :username,    String
      property :password,    String
      property :url,         String
      property :created_at,  DateTime
      property :updated_at,  DateTime
    EOS
  end
end

class Server
  include DataMapper::Resource
  include Account
  
  property :type, String
end

# Create or upgrade all tables at once, like magic
DataMapper.auto_upgrade!

# set utf-8 for outgoing
before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end
