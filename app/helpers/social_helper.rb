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

  def social_login_v2_enabled?
    Stormpath::Rails.config.web.callback.enabled &&
      Stormpath::Rails.config.web.client_api.enabled &&
      Stormpath::Rails.config.web.client_api.domain_name.present?
  end

  def facebook_enabled?
    Stormpath::Rails.config.web.facebook_app_id
  end

  def github_enabled?
    Stormpath::Rails.config.web.github_app_id
  end

  def google_enabled?
    Stormpath::Rails.config.web.google_app_id
  end

  def linkedin_enabled?
    Stormpath::Rails.config.web.linkedin_app_id
  end

  def link_to_facebook_login(url)
    link_to 'Facebook', url, class: 'btn btn-social btn-facebook' if facebook_enabled? && url.present?
  end

  def link_to_google_login(url)
    link_to 'Google', url, class: 'btn btn-social btn-google' if google_enabled? && url.present?
  end

  def link_to_linkedin_login(url)
    link_to 'LinkedIn', url, class: 'btn btn-social btn-linkedin' if linkedin_enabled? && url.present?
  end

  def link_to_github_login(url)
    link_to 'GitHub', url, class: 'btn btn-social btn-github' if github_enabled? && url.present?
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
