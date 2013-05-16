require 'rails'

module Stormpath
  module Rails
    mattr_accessor :logger

    class Railtie < ::Rails::Railtie
      initializer 'Rails logger' do
        Stormpath::Rails.logger = ::Rails.logger
      end
    end
  end
end