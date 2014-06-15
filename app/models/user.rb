class User

  include Mongoid::Document

  field :login
  field :company
  field :city
  field :country
  field :coordinates, :type => Array
  field :token

  index({ token: 1 }, { unique: true, name: "token_index" })

  validates :login, presence: true, format: /\A[a-zA-Z0-9._%+-]+\Z/, uniqueness: true
  validates :company, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validate :coordinates_validator

  before_create :update_token


  def address
    [city, country].join ', '
  end

  def name
    email.partition('@').first.gsub('.', ' ').titleize
  end

  def label
    name.split(' ').map(&:first).join
  end

  def coordinates_str= (str)
    self.coordinates = str.split(',').map do |n| n.to_f end
  end

  def email
    login + '@telecom-paristech.fr'
  end

  def self.exists? (cond)
    self.where(cond).count > 0
  end

  def update_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(token: random_token)
    end
  end


  private

  def coordinates_validator
    unless coordinates.length == 2 && coordinates[0].class == Float && coordinates[1].class == Float
      errors.add :coordinates, 'must be a couple of float'
    end
  end



end
