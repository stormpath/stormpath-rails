class StaticPagesController < ApplicationController
  before_action :require_authentication!

  def index
  end

  def about
  end
end
