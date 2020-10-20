module Auth
  class AuthorizeApiRequest
    def initialize(headers: {})
      @headers = headers
    end

    def call
      { user: user }
    end

    private

    attr_accessor :headers

    def user
      @user ||= User.find(decoded_auth_token['user_id']) if decoded_auth_token
    rescue ActiveRecord::RecordNotFound => e
      raise ApiPack::Errors::Auth::InvalidToken, ("Invalid token #{e.message}")
    end

    def decoded_auth_token
      @decoded_auth_token ||= ApiPack::JsonWebToken.decode(http_auth_header)
    end

    def http_auth_header
      return headers['Authorization'].split(' ').last if headers['Authorization'].present?

      raise(ApiPack::Errors::Auth::MissingToken, 'Missing token')
    end
  end
end
