require 'spec_helper'

describe Stormpath::Configuration do

  context 'when id_site is not specified' do
    before do
      Stormpath.configure do
      end
    end

    it 'defaults to false' do
      expect(Stormpath.conf.id_site).to eq false
    end
  end
end