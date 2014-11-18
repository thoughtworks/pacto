# -*- encoding : utf-8 -*-
require 'thor'

module Pacto
  module UI
    # Colors for HTTP Methods, intended to match colors of Swagger-UI (as close as possible with ANSI Colors)
    METHOD_COLORS = {
      'POST' => :green,
      'PUT'  => :yellow,
      'DELETE' => :red,
      'GET' => :blue,
      'PATCH' => :yellow,
      'HEAD' => :green
    }

    def self.shell
      @shell ||= Thor::Shell::Color.new
    end

    def self.deprecation(msg)
      $stderr.puts colorize(msg, :yellow) unless Pacto.configuration.hide_deprecations
    end

    def self.colorize(msg, color)
      return msg unless Pacto.configuration.color

      shell.set_color(msg, color)
    end

    def self.colorize_method(method)
      method_string = method.to_s.upcase

      color = METHOD_COLORS[method_string] || :red # red for unknown methods
      colorize(method_string, color)
    end
  end
end
