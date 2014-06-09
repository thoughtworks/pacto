module Pacto
  # Included this module so that Pacto::Resettable.reset_all will call your class/module's self.reset! method.
  module Resettable
    def self.resettables
      @resettables ||= []
    end

    def self.included(base)
      resettables << base
    end

    def self.reset_all
      resettables.each do |resettable|
        resettable.reset!
      end
      true
    end
  end
end
