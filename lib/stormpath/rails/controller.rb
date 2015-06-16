require 'stormpath/rails/authentication'
require 'stormpath/rails/authentication'

module Stormpath
  module Rails
    module Controller
      extend ActiveSupport::Concern

      include Stormpath::Authentication
    end
  end
end
