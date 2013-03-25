# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "stormpath-rails"
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Denis Grankin"]
  s.date = "2013-03-25"
  s.description = "Stormpath Rails integration"
  s.email = ["liquidautumn@gmail.com"]
  s.files = [".gitignore", ".rspec", ".travis.yml", "Gemfile", "Guardfile", "LICENSE.txt", "README.md", "Rakefile", "lib/generators/stormpath/rails/install/install_generator.rb", "lib/generators/stormpath/rails/migration/migration_generator.rb", "lib/generators/stormpath/rails/templates/stormpath.yml", "lib/generators/stormpath/rails/templates/update_account_model.rb", "lib/stormpath-rails.rb", "lib/stormpath/rails/account.rb", "lib/stormpath/rails/client.rb", "lib/stormpath/rails/config.rb", "lib/stormpath/rails/version.rb", "spec/fixtures/config/stormpath.yml", "spec/generators/install_generator_spec.rb", "spec/generators/migration_generator_spec.rb", "spec/integration/active_record_spec.rb", "spec/integration/mongoid_spec.rb", "spec/spec_helper.rb", "spec/stormpath/rails/config_spec.rb", "spec/support/rails.rb", "spec/support/stormpath_account_shared_examples.rb", "stormpath-rails.gemspec"]
  s.homepage = "http://www.stormpath.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.0"
  s.summary = "Stormpath SDK API Wrapper"
  s.test_files = ["spec/fixtures/config/stormpath.yml", "spec/generators/install_generator_spec.rb", "spec/generators/migration_generator_spec.rb", "spec/integration/active_record_spec.rb", "spec/integration/mongoid_spec.rb", "spec/spec_helper.rb", "spec/stormpath/rails/config_spec.rb", "spec/support/rails.rb", "spec/support/stormpath_account_shared_examples.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<stormpath-sdk>, ["~> 0.4.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_development_dependency(%q<generator_spec>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, [">= 0"])
      s.add_development_dependency(%q<railties>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, ["~> 2.2.1"])
      s.add_development_dependency(%q<rb-inotify>, ["~> 0.8.8"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<stormpath-sdk>, ["~> 0.4.0"])
      s.add_dependency(%q<rake>, ["~> 10.0.2"])
      s.add_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_dependency(%q<generator_spec>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<mongoid>, [">= 0"])
      s.add_dependency(%q<railties>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, ["~> 2.2.1"])
      s.add_dependency(%q<rb-inotify>, ["~> 0.8.8"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<stormpath-sdk>, ["~> 0.4.0"])
    s.add_dependency(%q<rake>, ["~> 10.0.2"])
    s.add_dependency(%q<rspec>, ["~> 2.12.0"])
    s.add_dependency(%q<generator_spec>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<mongoid>, [">= 0"])
    s.add_dependency(%q<railties>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, ["~> 2.2.1"])
    s.add_dependency(%q<rb-inotify>, ["~> 0.8.8"])
  end
end
