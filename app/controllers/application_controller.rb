class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include ApiPack::ApiHelper

  before_action :ensure_json_accept, :ensure_json_content_type, :authorize_request
  attr_reader :current_user

  private

  def ensure_json_accept
    return if request.headers['Accept'] =~ /vnd\.api\+json/

    render body: nil, status: 406
  end

  def ensure_json_content_type
    return if request.get? || request.headers['Content-Type'] =~ /vnd\.api\+json/

    render body: nil, status: 415
  end

  def authorize_request
    @current_user = (Auth::AuthorizeApiRequest.new(headers: request.headers).call)[:user]
  end
end
