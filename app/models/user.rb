class User

  include Mongoid::Document

  field :email
  field :company
  field :city
  field :country
  field :coordinates, :type => Array

  include Geocoder::Model::Mongoid
  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }

  validates :email, presence: true, format: /\A[a-zA-Z0-9._%+-]+@telecom\-paristech\.fr\Z/
  validates :company, presence: true
  validates :city, presence: true
  validates :country, presence: true


  def address
    [city, country].join ', '
  end

  def address_changed?
    country_changed? && city_changed?
  end

  def to_geojson
    """{
        type: 'Feature',
        properties: {
            title: '#{email}',
            'marker-color': '#f86767',
            'marker-size': 'large',
            'marker-symbol': 'star'
        },
        geometry: {
            type: 'Point',
            coordinates: #{coordinates}
        }
    }"""
  end

end
