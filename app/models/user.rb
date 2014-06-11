class User

  include Mongoid::Document

  field :email, type: String
  field :company, type: String
  field :city, type: String
  field :country, type: String
  field :latitude, type: Float
  field :longitude, type: Float

end
