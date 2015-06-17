require 'stormpath/rails/authentication'

module Stormpath
  module Rails
    module Controller
      extend ActiveSupport::Concern

      include Stormpath::Rails::Authentication
    end
  end
end
