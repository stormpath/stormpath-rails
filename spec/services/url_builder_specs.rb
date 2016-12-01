require 'spec_helper'

describe Stormpath::Rails::UrlBuilder, vcr: true do
  let(:request) { OpenStruct.new(scheme: scheme) }
  let(:build) { Stormpath::Rails::UrlBuilder.create(request, host, path) }

  describe 'http scheme' do
    let(:scheme) { 'http' }

    describe 'with host and path' do
      let(:host) { 'trooper.stormpath.com' }
      let(:path) { '/login' }

      it 'should return the url' do
        expect(build).to eq 'http://trooper.stormpath.com/login'
      end
    end

    describe 'without path' do
      let(:host) { 'trooper.stormpath.com' }
      let(:path) { nil }

      it 'should return the url' do
        expect(build).to eq 'http://trooper.stormpath.com'
      end
    end
  end

  describe 'https scheme' do
    let(:scheme) { 'https' }

    describe 'with host and path' do
      let(:host) { 'trooper.stormpath.com' }
      let(:path) { '/login' }

      it 'should return the url' do
        expect(build).to eq 'https://trooper.stormpath.com/login'
      end
    end

    describe 'without path' do
      let(:host) { 'trooper.stormpath.com' }
      let(:path) { nil }

      it 'should return the url' do
        expect(build).to eq 'https://trooper.stormpath.com'
      end
    end
  end
end
