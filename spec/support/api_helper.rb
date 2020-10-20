module ApiHelper
  def authenticate_header
    user = create(:user)
    response = Auth::AuthenticateUser.new(user.email, user.password).call
    { 
      'Authorization': "Bearer #{response}", 
      'Accept': 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json'
    }
  end

  def authenticate_user
    user = create(:user)
    { username: user.username, password: user.password }
  end

  def token_generator(user_id)
    ApiPack::JsonWebToken.encode({ user_id: user_id })
  end

  def expired_token_generator(user_id)
    ApiPack::JsonWebToken.encode({ user_id: user_id }, exp: 24.hours.ago.to_i)
  end

  def parse_json(response)
    JSON.parse(response.body)
  end
  
  def resquest_post(url:, params:, headers: valid_headers)
    post  url,
          headers: headers,
          params: params.to_json
  end

  def resquest_put(url:, params:, headers: valid_headers)
    put url,
        headers: headers,
        params: params.to_json
  end
  
  def resquest_get(url:, headers: headers_accept)
    get url,
        headers: headers
  end
  
  def headers_accept
    { 
      'Accept': 'application/vnd.api+json' 
    } 
  end

  def headers_content_type
    {
      'Content-Type': 'application/vnd.api+json'
    } 
  end
  
  def valid_headers
    { 
      'Accept': 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json'
    } 
  end

  def invalid_headers
    { 
      "Authorization" => nil,
      'Accept': '*/*' 
    } 
  end
end