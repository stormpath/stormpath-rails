shared_examples "stormpath account" do
  context "after initialize" do
    let(:account) { mock("account", get_href: "account_href") }

    let!(:logger) { Logger.new(STDERR) }

    before(:each) do
      subject.class::STORMPATH_FIELDS.each do |field_name|
        account.stub!("get_#{field_name}").and_return(field_name.to_s)
      end
      Logger.stub!(:new).and_return(logger)
      Stormpath::Rails::Client.stub!(:find_account).and_return(account)
    end

    it "should silently skip stormpath load if no stormpath_url set" do
      Stormpath::Rails::Client.should_not_receive(:find_account)
      expect { subject }.to_not raise_error
    end

    context "on find" do
      before(:each) do
        Stormpath::Rails::Client.stub!(:create_account!).and_return(account)
        subject.save!
      end

      it "should find account at stormpath" do
        Stormpath::Rails::Client.should_receive(:find_account).with(subject.stormpath_url)
        subject.class.all.first.stormpath_url.should == subject.stormpath_url
      end

      it "should setup object with data from stormpath" do
        Stormpath::Rails::Client.should_receive(:find_account).with(subject.stormpath_url).and_return(account)
        found = subject.class.where(stormpath_url: 'account_href').first
        (subject.class::STORMPATH_FIELDS - [:password]).each do |field_name|
          found.send(field_name).should == account.send("get_#{field_name}")
        end
      end

      it "should log warning if stormpath account update failed" do
        Stormpath::Rails::Client.stub!(:find_account).and_raise(ResourceError.new(mock("error", get_message: "Find failed")))
        logger.should_receive(:warn).with("Error loading Stormpath account (Find failed)")
        found = subject.class.where(stormpath_url: 'account_href').first
        subject.class::STORMPATH_FIELDS.each do |field_name|
          found.send(field_name).should be_nil
        end
      end
    end

  end


  context "before create" do
    it "should create account at stormpath and assign stormpath_url" do
      Stormpath::Rails::Client.should_receive(:create_account!).and_return(mock("account", get_href: "account_href"))
      subject.save!
      subject.stormpath_url.should == "account_href"
    end

    it "should add error if stormpath account creation failed" do
      Stormpath::Rails::Client.stub!(:create_account!).and_raise(ResourceError.new(mock("error", get_message: "Create failed")))
      subject.save
      subject.errors[:base].should == ["Create failed"]
    end
  end

  context "before update" do
    let(:account) { mock("account", get_href: "account_href") }

    before(:each) do
      Stormpath::Rails::Client.stub!(:create_account!).and_return(account)
      subject.save!
    end

    it "should silently skip stormpath update if no stormpath_url set" do
      subject.stormpath_url = nil
      Stormpath::Rails::Client.should_not_receive(:update_account!)
      expect { subject.save! }.to_not raise_error
    end

    it "should update account at stormpath" do
      Stormpath::Rails::Client.should_receive(:update_account!).with(subject.stormpath_url, anything())
      subject.save!
    end

    it "should add error if stormpath account update failed" do
      Stormpath::Rails::Client.stub!(:update_account!).and_raise(ResourceError.new(mock("error", get_message: "Update failed")))
      subject.save.should be_false
      subject.errors[:base].should == ["Update failed"]
    end
  end

  context "after destroy" do
    let(:account) { mock("account", get_href: "account_href") }

    let!(:logger) { Logger.new(STDERR) }

    before(:each) do
      Logger.stub!(:new).and_return(logger)
      Stormpath::Rails::Client.stub!(:create_account!).and_return(account)
      subject.save!
    end

    it "should silently skip stormpath delete if no stormpath_url set" do
      subject.stormpath_url = nil
      Stormpath::Rails::Client.should_not_receive(:delete_account!)
      expect { subject.destroy }.to_not raise_error
    end

    it "should destroy account at stormpath" do
      Stormpath::Rails::Client.should_receive(:delete_account!).with(subject.stormpath_url)
      subject.destroy
    end

    it "should log warning if stormpath account update failed" do
      Stormpath::Rails::Client.stub!(:delete_account!).and_raise(ResourceError.new(mock("error", get_message: "Delete failed")))
      logger.should_receive(:warn).with("Error destroying Stormpath account (Delete failed)")
      subject.destroy.should be_true
    end
  end
end
