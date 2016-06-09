require 'spec_helper'
require 'generators/stormpath/routes/routes_generator'

describe Stormpath::Generators::RoutesGenerator, :generator do
  it 'adds stormpath routes to existing rails routes' do
    provide_existing_routes_file

    routes = file('config/routes.rb')

    run_generator

    expect(routes).to have_correct_syntax
    expect(routes).to contain(
      "get '/login' => 'stormpath/sessions#new', as: 'sign_in'"
    )
  end
end
