require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"

require "rake"
require "rspec/core/rake_task"

namespace :dummy do
  require_relative "spec/dummy/config/application"
  Dummy::Application.load_tasks
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end