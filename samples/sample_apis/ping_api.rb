#  This illustrates a simple get service
module DummyServices
  class Ping < Grape::API
    format :json
    desc 'Ping'
    get '/ping' do
      { ping: "pong" }
    end
  end
end
