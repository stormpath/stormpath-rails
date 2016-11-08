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

  def facebook_oauth_url
    URI::HTTPS.build(
      host: 'www.facebook.com',
      path: '/dialog/oauth',
      query: {
        client_id: Stormpath::Rails.config.web.facebook_app_id,
        redirect_uri: facebook_callback_url,
        scope: Stormpath::Rails.config.web.social.facebook.scope
      }.to_query
    ).to_s
  end

  def github_oauth_url
    URI::HTTPS.build(
      host: 'www.github.com',
      path: '/login/oauth/authorize',
      query: {
        client_id: Stormpath::Rails.config.web.github_app_id,
        redirect_uri: github_callback_url,
        scope: Stormpath::Rails.config.web.social.github.scope
      }.to_query
    ).to_s
  end

  def google_oauth_url
    URI::HTTPS.build(
      host: 'accounts.google.com',
      path: '/o/oauth2/auth',
      query: {
        client_id: Stormpath::Rails.config.web.google_app_id,
        redirect_uri: google_callback_url,
        scope: Stormpath::Rails.config.web.social.google.scope,
        response_type: 'code'
      }.to_query
    ).to_s
  end

  def linkedin_oauth_url
    URI::HTTPS.build(
      host: 'www.linkedin.com',
      path: '/oauth/v2/authorization',
      query: {
        client_id: Stormpath::Rails.config.web.linkedin_app_id,
        redirect_uri: linkedin_callback_url,
        scope: Stormpath::Rails.config.web.social.linkedin.scope,
        response_type: 'code'
      }.to_query
    ).to_s
  end
end
