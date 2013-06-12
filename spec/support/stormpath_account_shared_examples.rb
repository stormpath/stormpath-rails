require "logger"

shared_examples "stormpath account" do
  let(:mock_account) do
    mock("account", href: "account_href").tap do |account|
      subject.class::STORMPATH_FIELDS.each do |field_name|
        account.stub!("#{field_name}").and_return(field_name.to_s)
      end
    end
  end

  context 'class methods' do
    let(:username) { 'test@example.com' }
    let(:email) { username }
    let(:password) { 'adsf1234' }
    let(:mock_user) { subject.class.new }

    describe '.authenticate' do
      before do
        Stormpath::Rails::Client.stub!(:authenticate_account).and_return(mock_account)
        subject.class.stub_chain(:where, :first).and_return(mock_user)
      end

      it 'returns an instance of the class into which the Account module was mixed in' do
        instance = subject.class.authenticate username, password
        instance.should be_a_kind_of(subject.class)
      end
    end

    describe '.send_password_reset_email' do
      before do
        Stormpath::Rails::Client.stub!(:send_password_reset_email).and_return(mock_account)
        subject.class.stub_chain(:where, :first).and_return(mock_user)
      end

      it 'returns an instance of the class into which the Account module was mixed in' do
        instance = subject.class.send_password_reset_email email
        instance.should be_a_kind_of(subject.class)
      end
    end

    describe '.verify_password_reset_token' do
      let(:token) { 'ASDF1324' }

      before do
        Stormpath::Rails::Client.stub!(:verify_password_reset_token).and_return(mock_account)
        subject.class.stub_chain(:where, :first).and_return(mock_user)
      end

      it 'returns an instance of the class into which the Account module was mixed in' do
        instance = subject.class.verify_password_reset_token token
        instance.should be_a_kind_of(subject.class)
      end
    end

    describe '.verify_account_email' do
      let(:token) { 'ASDF1324' }

      before do
        Stormpath::Rails::Client.stub!(:verify_account_email).and_return(mock_account)
        subject.class.stub_chain(:where, :first).and_return(mock_user)
      end

      it 'returns an instance of the class into which the Account module was mixed in' do
        instance = subject.class.verify_account_email token
        instance.should be_a_kind_of(subject.class)
      end
    end
  end

  before(:each) do
    Stormpath::Rails::Client.stub!(:find_account).and_return(mock_account)
    Stormpath::Rails.logger = Logger.new(STDERR)
  end

  context "after initialize" do
    context 'when no Stormpath URL property is set' do
      it "does NOT load data from stormpath on initialization" do
        Stormpath::Rails::Client.should_not_receive(:find_account)
        expect { subject }.to_not raise_error
      end
    end

    context 'when a Stormpath URL property is set' do
      let(:reloaded_subject) { subject.class.all.first }

      before(:each) do
        Stormpath::Rails::Client.stub!(:create_account!).and_return(mock_account)
        subject.save!
      end

      it "does NOT load data from stormpath on initialization" do
        Stormpath::Rails::Client.should_not_receive(:find_account)
        reloaded_subject.stormpath_url.should == subject.stormpath_url
      end
    end
  end

  context 'lazy load Stormpath fields' do
    let(:reloaded_subject) { subject.class.all.first }

    before(:each) do
      Stormpath::Rails::Client.stub!(:create_account!).and_return(mock_account)
      subject.save!
    end

    context 'when no Stormpath account field has ever been read' do
      (Stormpath::Rails::Account::STORMPATH_FIELDS - [:password]).each do |field_name|
        context "when the #{field_name} is read" do
          it "retrieves the account fields from Stormpath" do
            Stormpath::Rails::Client.should_receive(:find_account).with(subject.stormpath_url)
            reloaded_subject.send(field_name).should == mock_account.send(field_name)
          end

          it "logs a warning to standard output" do
            Stormpath::Rails::Client.stub!(:find_account).and_raise(Stormpath::Error.new(mock("error", message: "Find failed")))
            Stormpath::Rails.logger.should_receive(:warn).with("Error loading Stormpath account (Find failed)")
            reloaded_subject.send(field_name).should be_nil
          end
        end
      end
    end

    context 'when a Stormpath account field has previously been read' do
      before do
        Stormpath::Rails::Client.should_receive(:find_account).with(subject.stormpath_url).at_most(:once).and_return(mock_account)
        reloaded_subject.send :email
      end

      (Stormpath::Rails::Account::STORMPATH_FIELDS - [:password]).each do |field_name|
        context "when reading the #{field_name} attribute" do
          it 'does NOT retrieve the full account from Stormpath' do
            reloaded_subject.send(field_name).should == mock_account.send(field_name)
          end
        end
      end
    end
  end

  context "before create" do
    before(:each) do
      subject.email = 'foo@example.com'
      subject.given_name = 'Foo'
      subject.surname = 'Bar'

      Stormpath::Rails::Client.stub!(:create_account!).and_return mock_account
    end

    it "should create account at stormpath and assign stormpath_url" do
      subject.stormpath_url.should be_nil
      Stormpath::Rails::Client.should_receive(:create_account!).once.with(hash_including({
        :email => 'foo@example.com',
        :given_name => 'Foo',
        :surname => 'Bar'
      }))
      subject.save
      subject.stormpath_url.should == "account_href"
    end

    it "should add error if stormpath account creation failed" do
      Stormpath::Rails::Client.stub!(:create_account!).and_raise(Stormpath::Error.new(mock("error", message: "Create failed")))
      subject.save
      subject.errors[:base].should == ["Create failed"]
    end
  end

  context "before update" do
    before(:each) do
      Stormpath::Rails::Client.stub!(:create_account!).and_return(mock_account)
      subject.save!
    end

    it "skip silently stormpath update if no stormpath_url set" do
      subject.stormpath_url = nil
      expect { subject.save! }.to_not raise_error
    end

    it "should update account at stormpath" do
      subject.stormpath_account.should_receive(:save)
      subject.save!
    end

    it "should add error if stormpath account update failed" do
      subject.stormpath_account.stub!(:save).and_raise(Stormpath::Error.new(mock("error", message: "Update failed")))
      subject.save.should be_false
      subject.errors[:base].should == ["Update failed"]
    end
  end

  context "after destroy" do
    before(:each) do
      Stormpath::Rails::Client.stub!(:create_account!).and_return(mock_account)
      subject.save!
    end

    it "should silently skip stormpath delete if no stormpath_url set" do
      subject.stormpath_url = nil
      expect { subject.destroy }.to_not raise_error
    end

    it "should destroy account at stormpath" do
      subject.stormpath_account.should_receive(:delete)
      subject.destroy
    end

    it "should log warning if stormpath account update failed" do
      subject.stormpath_account.stub!(:delete).and_raise(Stormpath::Error.new(mock("error", message: "Delete failed")))
      Stormpath::Rails.logger.should_receive(:warn).with("Error destroying Stormpath account (Delete failed)")
      subject.destroy.should be_true
    end
  end
end
