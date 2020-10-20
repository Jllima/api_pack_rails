module FastJsonapi
  class UserSerializer < FastJsonapi::ApplicationSerializer
    attributes :name, :email, :username
  end
end
