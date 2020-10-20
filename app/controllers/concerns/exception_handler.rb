module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |e|
      result = ApiPack::Errors::HandleError.new(e).call
      json_response(result[:body], result[:status])
    end
  end
end
