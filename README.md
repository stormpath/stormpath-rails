# Stormpath::Rails

Ruby on Rails support for Stormpath

## Usage

add gem 'stormpath-rails' to Gemfile

run rails g stormpath:rails:install

edit config/stormpath.yml

export stormpath connection string to STORMPATH_URL (optional)

```ruby
class User < ActiveRecord:Base
    include Stormpath::Rails::Account
end
```

add stormpath_url column to store stormpath UID.

## TODO

Preventive validation to not send invalid data to stormpath.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
