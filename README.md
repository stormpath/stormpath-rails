# Stormpath-Rails-Gem

Stormpath is the first easy, secure user management and authentication service for developers. This is the Rails gem to ease integration of its features with any Rails-based application.

stormpath makes it incredibly simple to add users and user data to your application. It aims to completely abstract away all user registration, login, authentication, and authorization problems, and make building secure websites painless.

## INSTALL

To get started, add Stormpath to your `Gemfile`, `bundle install`, and run the
`install generator`:

generates inital config and setup files
```sh
$ rails generate stormpath:install
```

The generator:

* Inserts `Stormpath::Controller` into your `ApplicationController`
* Creates an initializer to allow further configuration.
* Creates a migration that either creates a users table or adds any necessary
  columns to the existing table.

# CONFIGURE
Override any of these defaults in config/initializers/stormpath.rb

```ruby
Stormpath::Rails.configure do |config|
  config.api_key.file = ENV['STORMPATH_API_KEY_FILE_LOCATION']
  config.application.href = ENV['STORMPATH_SDK_TEST_APPLICATION_URL']
end
```

# USAGE

### Access Control
Use the `require_login` to control access to controller actions
```ruby
class ArticlesController < ApplicationController
  before_action :require_login

  def index
  end
end
```

### Helper Methods
you can access user session for this scope:
```ruby
user_session
```

Use `current_user`, `signed_in?` in controllers, views, and helpers. For example:
```erb
<% if signed_in? %>
  <%= current_user.email %>
  <%= button_to "Sign out", sign_out_path, method: :delete %>
<% else %>
  <%= link_to "Sign in", sign_in_path %>
<% end %>
```
