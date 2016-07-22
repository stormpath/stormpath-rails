require 'spec_helper'
require 'generators/stormpath/views/views_generator'

describe Stormpath::Generators::ViewsGenerator, :generator do
  it 'copies stormpath views to host application' do
    run_generator

    views = %w(
      stormpath/rails/layouts/stormpath.html.erb
      stormpath/rails/change_password/new.html.erb
      stormpath/rails/forgot_password/new.html.erb
      stormpath/rails/login/new.html.erb
      stormpath/rails/login/_form.html.erb
      stormpath/rails/register/new.html.erb
      stormpath/rails/register/_form.html.erb
      stormpath/rails/shared/_input.html.erb
      stormpath/rails/verify_email/new.html.erb
    )

    view_files = views.map { |view| file("app/views/#{view}") }

    view_files.each do |each|
      expect(each).to exist
      expect(each).to have_correct_syntax
    end
  end
end
