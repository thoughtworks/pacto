module Pacto
  module Cops
    class RequestBodyCop < BodyCop
      validates :request
    end
  end
end

Pacto::Cops.register_cop Pacto::Cops::RequestBodyCop
