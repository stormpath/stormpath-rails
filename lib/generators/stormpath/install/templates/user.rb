class User < ActiveRecord::Base
  include Stormpath::Rails::User
end
