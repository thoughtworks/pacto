#  This illustrates a simple get service
module DummyServices
  class Hello < Grape::API
    format :json
    content_type :json, 'application/json'

    desc 'Hello'
    get '/hello' do
      header 'Vary', 'Accept'
      {message: 'Hello World!'}
    end
  end
end
