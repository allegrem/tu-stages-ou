class UserSerializer < ActiveModel::Serializer
  attributes :name, :company, :coordinates, :label, :city, :country
end
