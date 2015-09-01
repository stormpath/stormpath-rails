# Stormpath::Rails.configure do |config|
#   config.api_key_file = ENV['STORMPATH_API_KEY_FILE_LOCATION']
#   config.application = ENV['STORMPATH_SDK_TEST_APPLICATION_URL']
# end


binding.pry
Stormpath::Rails.configure do |config|
  config.id_site do |c|
    c.enabled = false
    c.uri = "/idSiteResult"
  end

  config.api_key do |c|
    c.file = ENV['STORMPATH_API_KEY_FILE_LOCATION']
  end
end
