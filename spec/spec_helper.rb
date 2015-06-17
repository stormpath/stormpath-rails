$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV["RAILS_ENV"] ||= "test"

require "rails/all"
require 'stormpath/rails'
require "dummy/config/environment"
require "rspec/rails"