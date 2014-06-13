class User

  include Mongoid::Document

  field :email
  field :company
  field :city
  field :country
  field :coordinates, :type => Array

  include Geocoder::Model::Mongoid
  geocoded_by :address

  validates :email, presence: true, format: /\A[a-zA-Z0-9._%+-]+@telecom\-paristech\.fr\Z/, uniqueness: true
  validates :company, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validate :geocode_coordinates


  def address
    [city, country].join ', '
  end

  def address_changed?
    country_changed? && city_changed?
  end

  def name
    email.partition('@').first.gsub('.', ' ').titleize
  end

  def label
    name.split(' ').map(&:first).join
  end

  def to_geojson
    """{
        type: 'Feature',
        properties: {
            title: '#{name} @ #{company}',
            'marker-color': '#f39c12',
            'marker-size': 'large',
            'marker-symbol': 'heart'
        },
        geometry: {
            type: 'Point',
            coordinates: #{coordinates}
        },
        attributes: {
          name: '#{name}',
          company: '#{company}'
        }
    }"""
  end


  private

  def geocode_coordinates
    if address.present? and address_changed?
      errors.add :address, 'was not found'  unless geocode
    end
  end

end
