module Auth
  class AuthenticateUser
    def initialize(email, password)
      @email = email
      @password = password
    end

    def call
      ApiPack::JsonWebToken.encode({ user_id: user.id }) if user
    end

    private

    attr_accessor :email, :password

    def user
      user = User.find_by(email: email)
      return user if user&.authenticate(password)

      raise(ApiPack::Errors::Auth::AuthenticationError, 'Invalid credentials')
    end
  end
end
