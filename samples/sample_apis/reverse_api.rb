# This illustrates simple get w/ params and post w/ body services
# It also illustrates having two services w/ the same endpoint (just different HTTP methods)
module DummyServices
  class Reverse < Grape::API
    format :txt

    helpers do
      def echo(message)
        error!('Bad Request', 400) unless message
        message
      end
    end

    # curl localhost:9292/api/echo -H 'Content-Type: application/json' -d '{"red fish": "blue fish"}' -vv
    post '/reverse' do
      echo(env['api.request.body']).reverse
    end
  end
end
