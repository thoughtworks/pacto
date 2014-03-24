require 'grape'
require 'grape-swagger'
require 'json'
Dir[File.expand_path('../*_api.rb', __FILE__)].each do |f|
    puts "Requiring #{f}"
  require f
end

module DummyServices
  class API < Grape::API
    prefix 'api'
    format :json
    mount DummyServices::Ping
    mount DummyServices::Echo
    mount DummyServices::Files
    mount DummyServices::Reverse
    # mount RescueFrom
    # mount PathVersioning
    # mount HeaderVersioning
    # mount PostPut
    # mount WrapResponse
    # mount PostJson
    # mount ContentType
    # mount UploadFile
    # mount Entities::API
    add_swagger_documentation # api_version: 'v1'
  end
end
DummyServices::API.routes.each do |route|
  p route
end
run DummyServices::API
