module Stormpath
  module Rails
    module UserConfig
      class ApiKey
        include Virtus.model

        attribute :file, String
        attribute :id, String
        attribute :secret, String
        
        def file_location_provided?
          !self.file.nil? 
        end
      end
    end
  end
end
