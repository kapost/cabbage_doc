require 'sinatra/base'
require 'haml'
require 'redcarpet'
require 'json'
require 'cgi'

module CabbageDoc
  module Helpers; end

  class Web < Sinatra::Base
    ROOT = File.expand_path("../../../web", __FILE__).freeze

    set :root, proc {
      dir = File.join(Configuration.instance.root, 'web')
      if Dir.exists?(dir)
        dir
      else
        ROOT
      end
    }
    set :public_folder, proc { "#{root}/public" }
    set :views, proc { "#{root}/views" }

    helpers WebHelper

    Dir.glob("#{root}/**/*.rb").sort.each do |helper|
      require helper
    end

    CabbageDoc::Helpers.constants.each do |c|
      mod = CabbageDoc::Helpers.const_get(c)
      helpers mod if mod.is_a?(Module)
    end

    get '/' do
      haml :index
    end

    get '/:id' do
      response_by_id(params[:id])
    end

    post '/' do
      response = Configuration.instance.request.call(post_request) if post_request.valid?

      if response.is_a?(Response)
        content_type :json
        response.to_json
      elsif post_request.valid?
        response_by_id(post_request.id)
      else
        halt 500
      end
    end
  end
end
