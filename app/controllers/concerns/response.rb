module Response
  def json_response(object, status = :ok, include = [])
    render json: object, status: status, include: include
  end

  def json_response_create(object, location, include = [])
    render json: object, status: :created, location: location, include: include
  end
end
