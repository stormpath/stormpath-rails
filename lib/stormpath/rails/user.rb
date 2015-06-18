module Stormpath
  module Rails
    module User
      extend ActiveSupport::Concern

      module ClassMethods
        def find_user(email)
          if user = find_by_normalized_email(email)
            return user
          end
        end

        def find_by_normalized_email(email)
          find_by_email normalize_email(email)
        end

        def normalize_email(email)
          email.to_s.downcase.gsub(/\s+/, "")
        end
      end
    end
  end
end