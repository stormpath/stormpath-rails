module SocialHelper
  def box_class
    social_providers_present? ? 'small col-sm-8' : 'large col-sm-12'
  end

  def label_class
    social_providers_present? ? 'col-sm-12' : 'col-sm-4'
  end

  def input_class
    social_providers_present? ? 'col-sm-12' : 'col-sm-8'
  end

  # TODO: What about the state checks? With them we could check if the request was created
  #       by a third party

  def facebook_oauth_url
    client_id = Stormpath::Rails.config.web.facebook_app_id
    redirect_uri = facebook_callback_url
    scope = Stormpath::Rails.config.web.social.facebook.scope
    url = 'https://www.facebook.com/dialog/oauth'
    "#{url}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}"
  end

  def github_oauth_url
    client_id = Stormpath::Rails.config.web.github_app_id
    redirect_uri = github_callback_url
    scope = Stormpath::Rails.config.web.social.github.scope
    url = 'https://github.com/login/oauth/authorize'
    "#{url}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}"
  end

  def google_oauth_url
    client_id = Stormpath::Rails.config.web.google_app_id
    redirect_uri = google_callback_url
    scope = Stormpath::Rails.config.web.social.google.scope
    response_type = 'code'
    url = 'https://accounts.google.com/o/oauth2/auth'
    "#{url}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&response_type=#{response_type}"
  end

  def linkedin_oauth_url
    client_id = Stormpath::Rails.config.web.linkedin_app_id
    redirect_uri = linkedin_callback_url
    scope = Stormpath::Rails.config.web.social.linkedin.scope
    response_type = 'code'
    url = 'https://www.linkedin.com/oauth/v2/authorization'
    "#{url}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&response_type=#{response_type}"
  end
end
