class User

  include Mongoid::Document

  field :login
  field :company
  field :city
  field :country
  field :coordinates, :type => Array

  validates :login, presence: true, format: /\A[a-zA-Z0-9._%+-]+\Z/, uniqueness: true
  validates :company, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validate :coordinates_validator


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


  private

  def coordinates_validator
    unless coordinates.length == 2 && coordinates[0].class == Float && coordinates[1].class == Float
      errors.add :coordinates, 'must be a couple of float'
    end
  end

end
