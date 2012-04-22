class User
  include Mongoid::Document

  field :login_id, type: String
  field :name, type: String
end
