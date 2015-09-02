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

### Helper Methods

Use `current_user`, `signed_in?`, `signed_out?` in controllers, views, and helpers. For example:
```erb
<% if signed_in? %>
  <%= current_user.email %>
  <%= button_to "Sign out", sign_out_path, method: :delete %>
<% else %>
  <%= link_to "Sign in", sign_in_path %>
<% end %>
```

### Verify Email

By default verify email is disabled. Which means after user fills in the registration form and submits, if his credentials are valid, he will be automaticly logged in without email verification.

If you want to enable email verification you can add the following code to the configuration file.

```erb
Stormpath::Rails.configure do |config|
  config.verify_email do |c|
    c.enabled = true
    c.uri = '/verify'
    c.next_uri = '/'
  end
end
```

If verify email set to enable after user registers he will first receive an email with the link and token with which he can verify his account. uri is the link which is used to verify the account and next_uri is location where user will be redirected after his account has been verified.

### Forgot Password

By default forgot password is disabled. To enable it add the following code to the configuration file

```erb
Stormpath::Rails.configure do |config|
  config.verify_email do |c|
    c.enabled = true
    c.uri = '/forgot'
    c.next_uri = '/'
  end
end
```

After the forgot password option has been enabled on the login form there will appear a link for user to reset his password. User first needs to enter an email to which a link will be send. When user clicks on a link he will be redirected to the final form where he can reset his passwod.

### ID Site

If you'd like to not worry about building your own registration and login screens at all, you can use Stormpath's new [ID site](https://docs.stormpath.com/guides/using-id-site/) feature. This is a hosted login subdomain which handles authentication for you automatically.

To make ID Site work in Rails, you need to change stormpath configuration file:

```ruby
Stormpath::Rails.configure do |config|
  config.id_site do |c|
    c.enabled = true
    c.uri = "/redirect"
  end
end
```

### Social Login

Stormpath Rails supports social login as well. Currently only Facebook is supported,  Providers for: Google, Github and Linkedin are currently in development. 

In order to enable Facebook login you first you need to create a Facebook application and create a Facebook directory in your stormpath account. More info can be found [here](https://docs.stormpath.com/rest/product-guide/#integrating-with-facebook). After that you need to enable id from storm paths configuration file and provide facebook app_id and app_secret which is provided to you after Facebook app creation.

```ruby
Stormpath::Rails.configure do |config|
  config.facebook do |c|
    c.app_id = 'app_id'
    c.app_secret = 'app_secret'
  end
end
```

When user navigates to `/login` he will see a facebook login button. If he is authenticated succesfully he will be redirected back to rails root_path.
