Stormpath::Rails.configure do |config|
  config.id_site do |c|
    c.enabled = false
    c.uri = "/idSiteResult"
  end

  config.api_key do |c|
    c.id = ENV['STORMPATH_API_KEY_ID']
    c.secret = ENV['STORMPATH_API_KEY_SECRET']
  end

  config.application.href = ENV['STORMPATH_APPLICATION_URL']

  config.facebook do |c|
    c.app_id = '913427355397270'
    c.app_secret = 'eddfb07802b3f3984989696bfb70a0ee'
  end
end
