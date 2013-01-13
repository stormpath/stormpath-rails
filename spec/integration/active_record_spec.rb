require "spec_helper"
require "active_record"
require "stormpath-rails"

describe "ActiveRecord record" do
  class ArEntity < ActiveRecord::Base
    include Stormpath::Rails::Account
  end

  subject { ArEntity.new }

  before(:each) do
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migration.create_table :ar_entities do |t|
      t.string :id
      t.string :stormpath_url
    end
  end

  it_should_behave_like "stormpath account"

end
