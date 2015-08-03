module Stormpath
  module Rails
    module User
      extend ActiveSupport::Concern

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