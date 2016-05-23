require 'yaml'

module CabbageDoc
  module Cloneable
    def clone
      YAML.load(YAML.dump(self))
    end
  end
end
