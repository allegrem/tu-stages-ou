class UserSerializer < ActiveModel::Serializer
  attributes :name, :company, :coordinates
end
