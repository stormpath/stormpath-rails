require 'spec_helper'

describe Stormpath::Rails::AccountStatus do
  describe '#error_message' do
    it 'returnes empty string if response is not of string type' do
      account_status = Stormpath::Rails::AccountStatus.new(1)
      expect(account_status.error_message).to eq('')
    end
  end
end
