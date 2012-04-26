class Tweet
  include Mongoid::Document

  field :user_id, type: String
  field :message, type: String
end
