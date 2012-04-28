class Tweet
  include Mongoid::Document

  field :user_id, type: String
  field :user_name, type: String
  field :time, type: DateTime
  field :message, type: String
end
