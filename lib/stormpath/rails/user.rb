module Stormpath
  module Rails
    module User
      extend ActiveSupport::Concern

      included do
        attr_accessor :password

        validates_presence_of :email
        validates_uniqueness_of :email
        validates_presence_of :given_name
        validates_presence_of :surname
      end

      module ClassMethods
        def find_user(email)
          find_by email: normalize_email(email)
        end

        def normalize_email(email)
          email.to_s.downcase.gsub(/\s+/, "")
        end
      end
    end
  end
end