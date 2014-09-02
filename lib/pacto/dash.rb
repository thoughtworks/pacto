require 'hashie'

module Pacto
  class Dash < Hashie::Dash
    include Hashie::Extensions::Coercion
    include Hashie::Extensions::Dash::IndifferentAccess
  end
end
