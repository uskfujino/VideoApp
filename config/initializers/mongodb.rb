# Mongoid設定
Mongoid.configure do |config|
  mongohq_url = ENV['MONGOHQ_URL']
  mongohq_db_name = ENV['MONGOHQ_DB']

  if mongohq_url && mongohq_db_name
    puts "MongoHQ Started"
    conn = Mongo::Connection.from_uri(mongohq_url)
    config.master = conn.db(mongohq_db_name)
  else
    puts "Local MongoDB Started"
    config.master = Mongo::Connection.new.db('bootstrap_haml')
  end
end
