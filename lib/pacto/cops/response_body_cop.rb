module Pacto
  module Cops
    class ResponseBodyCop < BodyCop
      validates :response
    end
  end
end

Pacto::Cops.register_cop Pacto::Cops::ResponseBodyCop
