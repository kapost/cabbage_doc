require 'fileutils'

module CabbageDoc
  class Customizer
    def perform
      FileUtils.cp_r(Web::ROOT, Configuration.instance.root)
    end
  end
end
