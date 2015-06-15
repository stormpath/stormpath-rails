require 'spec_helper'

describe Stormpath::Configuration do

  context 'when id_site is not specified' do
    before do
      Stormpath.configure do
      end
    end

    it 'defaults to false' do
      expect(Stormpath.config.id_site).to eq false
    end
  end

  context 'when is_site is set to true' do
    before do
      Stormpath.configure do |config|
        config.id_site = true
      end
    end

    it 'returns true' do
      expect(Stormpath.config.id_site).to eq true
    end
  end

  context 'when expand_custom_data is not specified' do
    before do
      Stormpath.configure do
      end
    end

    it 'defaults to false' do
      expect(Stormpath.config.expand_custom_data).to eq true
    end
  end
end