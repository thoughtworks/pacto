require 'term/ansicolor'

module Pacto
  module UI
    extend Term::ANSIColor

    def self.deprecation(msg)
      $stderr.puts yellow(msg) unless Pacto.configuration.hide_deprecations
    end
  end
end
