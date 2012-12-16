require 'spec_helper'
require 'stormpath/rails/config'

describe Stormpath::Rails::Config do
  before(:each) do
    Rails.stub!(:root).and_return(File.join File.dirname(__FILE__), "..", "..", "fixtures")
    Rails.stub!(:env).and_return("test")
  end

  context "file IO" do
    let(:path) { "#{Rails.root}/config/stormpath.yml" }

    before(:each) do
      described_class.vars = nil
    end

    it "should read yaml from rails app config/stormpath.yml" do
      File.should_receive(:read).with(path).and_call_original
      described_class[:href].should == 'stormpath_url'
    end

    it "should not re-red yaml once loaded" do
      File.should_receive(:read).with(path).and_call_original
      described_class[:href].should == 'stormpath_url'
      described_class[:href].should == 'stormpath_url'
    end
  end

  %w{test development production}.each do |environment|
    it "should read root directory from #{environment} yaml section" do
      Rails.stub!(:env).and_return(environment)
      described_class[:root].should == "#{environment}_root"
    end

    it "should mix shared vars to #{environment} env" do
      Rails.stub!(:env).and_return(environment)
      described_class[:href].should == 'stormpath_url'
      described_class[:application].should == 'application_url'
    end
  end
end
