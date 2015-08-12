class User < ActiveRecord::Base
  include Stormpath::Rails::User
  attr_accessor :password
end
