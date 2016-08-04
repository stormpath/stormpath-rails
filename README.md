[![Build Status](https://travis-ci.org/stormpath/stormpath-rails.svg?branch=master)](https://travis-ci.org/stormpath/stormpath-rails)
[![Coverage Status](https://coveralls.io/repos/stormpath/stormpath-rails/badge.svg?branch=master&service=github)](https://coveralls.io/github/stormpath/stormpath-rails?branch=master)
[![Code Climate](https://codeclimate.com/github/stormpath/stormpath-rails/badges/gpa.svg)](https://codeclimate.com/github/stormpath/stormpath-rails)

# Stormpath Rails

Stormpath is the first easy, secure user management and authentication service for developers. This is the Rails gem to ease integration of its features with any Rails-based application.

Stormpath makes it incredibly simple to add users and user data to your application. It aims to completely abstract away all user registration, login, authentication, and authorization problems, and make building secure websites painless.

## Installation

Stormpath Rails officially supports Ruby versions over 2.1.0 and Rails over 4.0.

Add the stormpath-rails integration gem to your Gemfile.

Stormpath is currently in beta so it is necessary to include the gem version:

```ruby
gem 'stormpath-rails', '~> 2.0.0'
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

### Add Routes

Add `stormpath_rails_routes` to your routes.rb file.

```ruby
Rails.application.routes.draw do
  stormpath_rails_routes
  ...
end
```

Check below on how to override default routes.

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

### HTML & JSON

Stormpath Rails responds to two formats: HTML & JSON. You can use it both as an API for building SPA's, mobile applications and as a standalone Rails application that renders HTML.

By default the Stormpath integration will respond to JSON and HTML requests. 
If a requested type isn't any of the two, the Stormpath integration will pass on the request, and allow the developer or Rails defaults to handle the response.

However if you want use only one of those, modify the configuration file:

```yaml
stormpath:
  web:
    produces:
      - application/json
      - text/html
```
If the request does not specify an Accept header, or the preferred content type is `*/*` the Stormpath integration will respond with the first type in the list.

### Controller private & helper methods.

The Application Controller gets the `Stormpath::Rails::Controller` module included by default.
The module provides 4 private controller methods:

- `current_account` - get the current account
- `signed_in?` - check if the user is signed in.
- `require_authentication!` - a before filter to stop unauthenticated access.
- `require_no_authentication!` - a before filter to stop authenticated access (a logged in user shouldn't be able to see the login form).

By default, the `current_account` and `signed_in?` are marked as helper_methods and you can use them in your views.

If you wish to add these methods to a controller that doesn't inherit from the ApplicationController, just include the `Stormpath::Rails::Controller` module in that controller as well.

## Overriding Stormpath

### Controllers

Since Stormpath controllers are highly configurable, they have lots of configuration code and are not written in a traditional way. A LoginController would usually have two actions - new & create, however in StormpathRails they are separated into two single action controllers - `Stormpath::Rails::Login::NewController` and `Stormpath::Rails::Login::CreateController`. They both respond to a `call` method (action).

To override a Stormpath controller, first you need to subclass it:

```ruby
class CreateAccountController < Stormpath::Rails::Register::CreateController
end
```

and update the routes to point to your new controller:

```ruby
Rails.application.routes.draw do
  stormpath_rails_routes(actions: { 
    'register#create' => 'create_account#call'
  })
end
```

List of available controllers:

```ruby
Stormpath::Rails::Login::NewController
Stormpath::Rails::Login::CreateController

Stormpath::Rails::Logout::CreateController

Stormpath::Rails::Register::NewController
Stormpath::Rails::Register::CreateController

Stormpath::Rails::ChangePassword::NewController
Stormpath::Rails::ChangePassword::CreateController

Stormpath::Rails::ForgotPassword::NewController
Stormpath::Rails::ForgotPassword::CreateController

Stormpath::Rails::VerifyEmail::ShowController
Stormpath::Rails::VerifyEmail::CreateController

Stormpath::Rails::Profile::ShowController

Stormpath::Rails::Oauth2::NewController
Stormpath::Rails::Oauth2::CreateController
```

### Routes

To override routes (while using Stormpath default controllers), please use the configuration file (config/stormpath.yml) and override them there. As usual, to see what the routes are, run `rake routes`.

### Views
You can use the Stormpath views generator to copy the default views to your application for modification:
```sh
rails generate stormpath:views
```

```
stormpath/rails/layouts/stormpath.html.erb

stormpath/rails/login/new.html.erb
stormpath/rails/login/_form.html.erb

stormpath/rails/register/new.html.erb
stormpath/rails/register/_form.html.erb

stormpath/rails/change_password/new.html.erb

stormpath/rails/forgot_password/new.html.erb

stormpath/rails/shared/_input.html.erb

stormpath/rails/verify_email/new.html.erb
```

## Development

### Prerequisites

If you wish to contribute to the gem, please follow these steps:

1. Create a Stormpath Application.
2. Export the following env variables:
  - STORMPATH_API_KEY_ID
  - STORMPATH_API_KEY_SECRET
3. Create a Directory and associate it to the app. Make it the default account and group store for the app.
4. Create a Directory With a Verification Workflow and associate it to the app.
5. Export the following env variable:
  - STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL

### Specs

Clone the repo & install the dependencies with `bundle install`.
The suite is written with RSpec, so to run the specs you'll need to execute `rspec`
The suite uses the [VCR gem](https://github.com/vcr/vcr) to record all the HTTP requests. On first roll it records them and after that all of the tests use the recorded HTTP requests and run under 10 seconds.
