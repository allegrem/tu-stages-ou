class User

  include Mongoid::Document

  field :email, type: String
  field :company, type: String
  field :city, type: String
  field :country, type: String
  field :latitude, type: Float
  field :longitude, type: Float

  validates :email, presence: true, format: /\A[a-zA-Z0-9._%+-]+@telecom\-paristech\.fr\Z/
  validates :company, presence: true
  validates :city, presence: true
  validates :country, presence: true

end
