require 'stormpath/authentication'
require 'rails/client'

module Stormpath
  module Controller
    extend ActiveSupport::Concern

    include Stormpath::Authentication
  end
end
