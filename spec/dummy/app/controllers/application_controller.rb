class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Stormpath::Rails::Controller

  protect_from_forgery with: :exception

  def show
    render text: '', layout: 'application'
  end
end
