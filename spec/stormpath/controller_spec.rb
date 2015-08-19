require "spec_helper"

describe Stormpath::Rails::Controller, type: :controller do
  controller(ActionController::Base) do
    include Stormpath::Rails::Controller
  end

  it "exposes no action methods" do
    expect(controller.action_methods).to be_empty
  end
end
