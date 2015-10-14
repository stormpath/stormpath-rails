Stormpath::Rails.configure do |config|
  config.api_key.file = ENV['STORMPATH_API_KEY_FILE_LOCATION']
  config.application.href = ENV['STORMPATH_SDK_TEST_APPLICATION_URL']
end
