require 'spec_helper'

class HelperMethodsController < ActionController::Base
  include Stormpath::Rails::Controller
end

describe HelperMethodsController, type: :controller do

  controller do
    def index
      render text: 'response'
    end
  end

  describe '#signed_in?' do
    it "returnes true when user signed_in" do
      sign_in
      get :index
      expect(controller.send(:signed_in?)).to be true
    end

    it "returnes false when user not signed_in" do
      get :index
      expect(controller.send(:signed_in?)).to be false
    end
  end

  describe '#signed_out?' do
    it "returnes true when user signed_in" do
      sign_in
      get :index
      expect(controller.send(:signed_out?)).to be false
    end

    it "returnes false when user not signed_in" do
      get :index
      expect(controller.send(:signed_out?)).to be true
    end
  end

  describe '#current_user' do
    it "returnes current_user" do
      sign_in
      get :index
      expect(controller.send(:current_user)).to eq(test_user)
    end
  end
end
