Stormpath::Rails.configure do |config|
  binding.pry
  config.id_site do |c|
    c.enabled = false
    c.uri = "/idSiteResult"
  end

  config.api_key.file = ENV['STORMPATH_API_KEY_FILE_LOCATION']
  config.application.href = ENV['STORMPATH_SDK_TEST_APPLICATION_URL']

  config.facebook do |c|
    c.app_id = '913427355397270'
    c.app_secret = 'eddfb07802b3f3984989696bfb70a0ee'
  end
end
