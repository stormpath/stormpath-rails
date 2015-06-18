class Stormpath::BaseController < ApplicationController
  protected

  def set_flash_message(key, message)
    flash[key] = message if message.present?
  end

  def initialize_session(display_name, stormpath_account_url)
    session[:display_name] = display_name
    session[:stormpath_account_url] = stormpath_account_url
  end
end