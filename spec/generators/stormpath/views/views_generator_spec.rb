require 'spec_helper'
require 'generators/stormpath/views/views_generator'

xdescribe Stormpath::Generators::ViewsGenerator, :generator do
  it 'copies stormpath views to host application' do
    run_generator

    views = %w(
      layouts/stormpath.html.erb
      passwords/email_sent.html.erb
      passwords/edit.html.erb
      passwords/forgot.html.erb
      sessions/_form.html.erb
      sessions/new.html.erb
      users/_form.html.erb
      users/new.html.erb
    )

    view_files = views.map { |view| file("app/views/#{view}") }

    view_files.each do |each|
      expect(each).to exist
      expect(each).to have_correct_syntax
    end
  end
end
