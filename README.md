[![Build Status](https://travis-ci.org/stormpath/stormpath-rails.svg?branch=master)](https://travis-ci.org/stormpath/stormpath-rails)
[![Coverage Status](https://coveralls.io/repos/stormpath/stormpath-rails/badge.svg?branch=master&service=github)](https://coveralls.io/github/stormpath/stormpath-rails?branch=master)
[![Code Climate](https://codeclimate.com/github/stormpath/stormpath-rails/badges/gpa.svg)](https://codeclimate.com/github/stormpath/stormpath-rails)

# Stormpath Rails

Stormpath is the first easy, secure user management and authentication service for developers. This is the Rails gem to ease integration of its features with any Rails-based application.

Stormpath makes it incredibly simple to add users and user data to your application. It aims to completely abstract away all user registration, login, authentication, and authorization problems, and make building secure websites painless.

## Installation

Add the stormpath-rails integration gem to your Gemfile.

Stormpath is currently in beta so it is necessary to include the gem version:

```ruby
gem 'stormpath-rails', '~> 2.0.0.beta1'
```

Bundle the Gemfile

```ruby
bundle install
```

Run the generator to insert the config yaml file and the neccessary controller module.

```sh
rails generate stormpath:install
```

## Setup

### Api Key Setup

Create a Stormpath account if you haven't already, and be sure to set up the following environment variables:

 - STORMPATH_API_KEY_ID
 - STORMPATH_API_KEY_SECRET

Environment variables should be set up in you .bashrc file (or .zshrc if you use myzsh).

Example setup:

```sh
export STORMPATH_API_KEY_ID=6U4HZMHGVHN0U765BGW
export STORMPATH_API_KEY_SECRET=0e0TuVZKYiPiLTDLNnswEwpPpa5nPv
```

Alternatively you can use gems such as [Dotenv](https://github.com/bkeepers/dotenv) or [Figaro](https://github.com/laserlemon/figaro) to preload environment variables.

### Application Setup

Create a Stormpath Application throught the Stormpath Admin Console.

Add the app href **OR** name to your configuration file in config/stormpath.yml:

```yaml
stormpath:
  application:
    href: https://api.stormpath.com/v1/applications/12345abc
    name: null
```

- Make sure your application has a default account directory.

- Make sure that you have the `root_path` defined in your rails `routes.rb`

## Configuration

The gem is highly configurable through it's configuration file (config/stormpath.yml).
Currently the only configurations not working are for social logins and ID Site (because they are still not implemented in the gem).

You can use embedded ruby (ERB) in the configuration file:

```yaml
stormpath:
  application:
    href: <%= ENV['STORMPATH_APPLICATION_URL'] %>
```

## Usage

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

### Login

Stormpath Rails automatically provides a `/login` route. If the attempt is successful, the user will be send to the `next_uri` which is by default `/` and create the proper session cookies.

If you wish to change this you can modify login options in configuration file:

```ruby
Stormpath::Rails.configure do |config|
  config.login do |c|
    c.enabled = true
    c.uri = '/login'
    c.next_uri = '/'
  end
end
```

### Logout
Stormpath Rails automatically provides route to `/logout`.

If you wish to change the logout URI or the `next_uri`, you can provide the following configuration:

```ruby
Stormpath::Rails.configure do |config|
  config.logout do |c|
    c.enabled = true
    c.uri = '/logout'
    c.next_uri = '/'
  end
end
```

### Verify Email

By default verify email is disabled, so after the user fills in the registration form and submits, if his credentials are valid, he will automatically be logged in without email verification.

If you want to enable email verification you can add the following code to the configuration file.  

```ruby
Stormpath::Rails.configure do |config|
  config.verify_email do |c|
    c.enabled = true
    c.uri = '/verify'
    c.next_uri = '/'
  end
end
```

If email verification is enabled, after the user registers he will first receive an email with the link and token with which he can verify his account. `uri` is the link which is used to verify the account and `next_uri` is the location where the user will be redirected after his account has been verified.

The email that is sent to the account is configurable through the [Stormpath Admin Console](https://api.stormpath.com).

### Forgot Password

By default forgot password is disabled. To enable it add the following code to the configuration file:

```ruby
Stormpath::Rails.configure do |config|
  config.verify_email do |c|
    c.enabled = true
    c.uri = '/forgot'
  end
end
```

After the forgot password option has been enabled on the login form, a reset password link will appear. After the user fills in his email and clicks on the link, he will be redirected to the final form where he can reset his password.

The forgot password email is configurable through the [Stormpath Admin Console](https://api.stormpath.com).

### ID Site

If you'd like to not worry about building your own registration and login screens at all, you can use Stormpath's new [ID site](https://docs.stormpath.com/guides/using-id-site/) feature. This is a hosted login subdomain which handles authentication for you automatically.

To make the ID Site work in Rails, you need to change the Stormpath config file:

```ruby
Stormpath::Rails.configure do |config|
  config.id_site do |c|
    c.enabled = true
    c.uri = "/redirect"
    c.next_uri = '/'
  end
end
```

When the ID Site is enabled, any request on `/login` or `/register` will redirect to the ID Site. When the user finishes the process at the ID Site, they will be redirected to an uri which is defined in configuration (the default route is `'/redirect'`). Stormpath Rails will handle this request and redirect the user to `next_uri`.

### Social Login

Stormpath Rails supports social login as well. Currently only Facebook is supported, while providers for Google, Github and Linkedin are currently in development.

In order to enable Facebook login you first you need to create a Facebook application and create a Facebook directory in your stormpath account. More info can be found [here](https://docs.stormpath.com/rest/product-guide/#integrating-with-facebook). After that you need to enable it through the Stormpath Rails config file by filling in the facebook app_id and app_secret which is provided to you after you've create the Facebook app.

```ruby
Stormpath::Rails.configure do |config|
  config.facebook do |c|
    c.app_id = 'app_id'
    c.app_secret = 'app_secret'
  end
end
```

When user navigates to `/login` he will see a Facebook login button. If he is authenticated successfully, he will be redirected back to the `root_path`.

## Overriding Stormpath

### Routes
You can optionally dump a copy of the default routes into your application for modification:

```sh
rails generate stormpath:routes
```

### Controllers
To override a Stormpath controller, subclass it and update the routes to point to your new controller (see the "Routes" section):
```ruby
class PasswordsController < Stormpath::Rails::PasswordsController
class SessionsController < Stormpath::Rails::SessionsController
class UsersController < Stormpath::Rails::UsersController
```

### Views
You can use the Stormpath views generator to copy the default views to your application for modification:
```sh
rails generate stormpath:views
```

```
app/views/layouts/stormpath.html.erb

app/views/passwords/edit.html.erb
app/views/passwords/email_sent.html.erb
app/views/passwords/forgot.html.erb
app/views/passwords/forgot_change.html.erb
app/views/passwords/forgot_change_failed.html.erb
app/views/passwords/forgot_complete.html.erb

app/views/sessions/_facebook_login_form.erb
app/views/sessions/_form.html.erb
app/views/sessions/new.html.erb

app/views/users/_form.html.erb
app/views/users/new.html.erb
app/views/users/verification_complete.html.erb
app/views/users/verification_email_sent.html.erb
app/views/users/verification_failed.html.erb
app/views/users/verification_resend.html.erb
```

### Supported Ruby Versions

* Ruby 2.0.0
* Ruby 2.1
* Ruby 2.2

### Supported Rails Versions

above Rails 3.2

## Development

### Prerequisites

If you wish to contribute to the gem, please follow the following steps:

1. Create a Stormpath Application.
2. Export the following env variables:
  - STORMPATH_API_KEY_ID
  - STORMPATH_API_KEY_SECRET
3. Create a Directory and associate it to the app. Make it the default account and group store for the app.
4. Create a Directory With a Verification Workflow and associate it to the app.
5. Export the following env variable:
  - STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL

### Specs

Clone the repo & install the dependencies with `bundler install`.
The suite is written with RSpec, so to run the specs you'll need to execute `rspec`
The suite uses the [VCR gem](https://github.com/vcr/vcr) to record all the HTTP requests. On first roll it records them and after that all of the tests use the recorded HTTP requests and run under 10 seconds.
