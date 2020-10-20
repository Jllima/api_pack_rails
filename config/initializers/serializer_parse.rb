# serializer default is Fast json api
Rails.application.config.to_prepare do
  ApiPack::Serializer::Parser.adapter = :fast_json_api
end
