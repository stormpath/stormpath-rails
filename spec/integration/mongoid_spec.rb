require "spec_helper"
require 'mongoid'
require "stormpath-rails"

describe "Mongoid integration" do
  class MongoidEntity
    include Mongoid::Document
    include Stormpath::Rails::Account
  end

  subject { MongoidEntity.new }

  before(:each) do
    Mongoid::Config.connect_to("stormpath_rails_test")
  end

  it_should_behave_like "stormpath account"

end
