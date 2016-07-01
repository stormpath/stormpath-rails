require 'spec_helper'

describe Stormpath::Rails::Config::AccountStoreVerification, vcr: true do
  let(:account_store_verification_class) { Stormpath::Rails::Config::AccountStoreVerification }
  let(:account_store_verification) do
    account_store_verification_class.new(app_href, register_is_enabled)
  end
  let(:app_href) { Stormpath::Rails::Client.application.href }
  let(:register_is_enabled) { true }

  describe 'application with account stores' do
    describe 'and with a default account store' do
      describe 'with register module enabled' do
        let(:register_is_enabled) { true }

        it 'doesnt error out' do
          expect do
            account_store_verification.call
          end.not_to raise_error
        end
      end

      describe 'with register module disabled' do
        let(:register_is_enabled) { false }

        it 'doesnt error out' do
          expect do
            account_store_verification.call
          end.not_to raise_error
        end
      end
    end

    describe 'but without a default account store' do
      before do
        allow(account_store_verification).to receive(:app_has_default_account_store_mapping?).and_return(false)
      end
      describe 'with register module enabled' do
        let(:register_is_enabled) { true }
        it 'errors out' do
          expect do
            account_store_verification.call
          end.to raise_error(Stormpath::Rails::InvalidConfiguration)
        end
      end

      describe 'with register module disabled' do
        let(:register_is_enabled) { false }

        it 'doesnt error out' do
          expect do
            account_store_verification.call
          end.not_to raise_error
        end
      end
    end
  end

  describe 'application without account stores' do
    it 'errors out' do
      allow(account_store_verification).to receive(:app_has_account_store_mappings?).and_return(false)

      expect do
        account_store_verification.call
      end.to raise_error(Stormpath::Rails::InvalidConfiguration)
    end
  end
end
