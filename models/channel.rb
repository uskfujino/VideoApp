class Channel
  include Mongoid::Document

  field :name, type: String
  field :owner_id, type: String
  field :owner_name, type: String
end
