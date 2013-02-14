[![Build Status](https://secure.travis-ci.org/stormpath/stormpath-rails.png)](http://travis-ci.org/stormpath/stormpath-rails)

# Ruby on Rails support for Stormpath

## Gem Setup

Reference gem from Gemfile.

```ruby
add gem 'stormpath-rails' to Gemfile
```

Generate configuration file, then create directory per environment at stormpath and update stormpath.yml with corresponding directory hrefs.

```sh
rails g stormpath:rails:install
```


Generate and run migration, if you're on ActiveRecord. Skip this step for Mongoid.

```sh
rails g stormpath:rails:migration user
rake db:migrate
```

Update your model file.

```ruby
class User < ActiveRecord:Base
  include Stormpath::Rails::Account
end
```

## TODO

+ Automatic directory layout (test, development, production) creation
+ Preventive validation to not send invalid data to stormpath.
+ Preventive validation to not send invalid data to stormpath.
+ Solve n+1 request problem when requesting account collection.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
