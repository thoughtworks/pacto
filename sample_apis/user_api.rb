# -*- encoding : utf-8 -*-
# A siple JSON service to demonstrate request/response bodies

require 'securerandom'

module DummyServices
  class Echo < Grape::API
    format :json

    post '/users' do
      user = env['api.request.body']
      user[:id] = SecureRandom.uuid
      user
    end
  end
end
