[![Build Status](https://travis-ci.org/stormpath/stormpath-rails.svg?branch=master)](https://travis-ci.org/stormpath/stormpath-rails)
[![Code Climate](https://codeclimate.com/github/stormpath/stormpath-rails/badges/gpa.svg)](https://codeclimate.com/github/stormpath/stormpath-rails)

# Stormpath Rails

Stormpath is the first easy, secure user management and authentication service for developers. This is the Rails gem to ease integration of its features with any Rails-based application.

Stormpath makes it incredibly simple to add users and user data to your application. It aims to completely abstract away all user registration, login, authentication, and authorization problems, and make building secure websites painless.

## Installation

Stormpath Rails officially supports Ruby versions over 2.1.0 and Rails over 4.0.

Add the stormpath-rails integration gem to your Gemfile.

Stormpath is currently in beta so it is necessary to include the gem version:

```ruby
gem 'stormpath-rails', '~> 2.3.1'
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

 - STORMPATH_CLIENT_APIKEY_ID
 - STORMPATH_CLIENT_APIKEY_SECRET

Environment variables should be set up in you .bashrc file (or .zshrc if you use myzsh).

Example setup:

```sh
export STORMPATH_CLIENT_APIKEY_ID=6U4HZMHGVHN0U765BGW
export STORMPATH_CLIENT_APIKEY_SECRET=0e0TuVZKYiPiLTDLNnswEwpPpa5nPv
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

You can use embedded ruby (ERB) in the configuration file:

```yaml
stormpath:
  application:
    href: <%= ENV['STORMPATH_APPLICATION_HREF'] %>
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

Stormpath::Rails::SocialController
Stormpath::Rails::Facebook::CreateController
Stormpath::Rails::Github::CreateController
Stormpath::Rails::Google::CreateController
Stormpath::Rails::Linkedin::CreateController
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
stormpath/rails/shared/_social_login.html.erb

stormpath/rails/verify_email/new.html.erb
```

## Social Authentication

In order to successfully authenticate via a social provider you need to set up your directories and account stores on your application. The Social Login Providers currently supported by Stormpath are Facebook, GitHub, Google and LinkedIn.

Social Directories are a kind of mirrored Directory, in that they are used to mirror user information found in an external database. This means that entities like Groups can only exist in a your Stormpath Social Directory if they are mirrored in from the external Social provider.

### Google
- create an application in the [Google Developer Console](https://console.developers.google.com/start)
- enable Google Login for your Google application
- copy the OAuth Credentials (Client ID and Secret) for your Google application
- in the Credentials tab you will see the Restrictions section. Write the origin URI of your application in the Authorized JavaScript origins field. For example, if you want to test logging in via Google locally, you can write http://localhost:3000
- In the authorized redirect URIs type in the callback URI to which Google is going to redirect after successful authentication: http://localhost:3000/callbacks/google
- log in to [your stormpath dashboard](https://api.stormpath.com/login) and visit the Directories section
- click on Create Directory and choose Google as the Directory Type. Name it and describe it however you want
- paste the copied OAuth Credentials that you copied when you created the Google application in the Google Client ID and secret fields
- paste the same authorized redirect URI as you did in the Google dashboard
- visit the Applications section and click on the application you're using
- click on Account Stores in the left sidebar and click on Add Account Store button
- after you add your newly created Google directory try starting up your server and visit /login. You should see the 1-click Google login button

### Facebook
- create an application on the [Facebook Developer Site](https://developers.facebook.com/)
- copy your OAuth credentials (App ID and App Secret)
- add your application’s private and public root URLs. You can use http://localhost:3000 if you're testing logging in locally
- make sure you make your application public by clicking on the App review tab in the left sidebar and activating your Facebook application
- log in to [your stormpath dashboard](https://api.stormpath.com/login) and visit the Directories section
- click on Create Directory and choose Facebook as the Directory Type. Name it and describe it however you want
- paste the copied OAuth Credentials that you copied when you created the Facebook application in the Facebook Client ID and secret fields
- visit the Applications section and click on the application you're using
- click on Account Stores in the left sidebar and click on Add Account Store button
- after you add your newly created Facebook directory try starting up your server and visit /login. You should see the 1-click Facebook login button

### GitHub
- create an application in the [GitHub Developer Site](https://github.com/settings/applications/new)
- copy the OAuth Credentials (Client ID and Secret) for your GitHub application
- add your application’s redirect URL, which is the URL the user will be returned to after successful authentication. You can use http://localhost:3000 if you're testing logging in locally
- log in to [your stormpath dashboard](https://api.stormpath.com/login) and visit the Directories section
- click on Create Directory and choose GitHub as the Directory Type. Name it and describe it however you want
- paste the copied OAuth Credentials that you copied when you created the GitHub application in the GitHub Client ID and secret fields
- visit the Applications section and click on the application you're using
- click on Account Stores in the left sidebar and click on Add Account Store button
- after you add your newly created GitHub directory try starting up your server and visit /login. You should see the 1-click GitHub login button

### LinkedIn
- create an application in the [LinkedIn Developer Site](https://www.linkedin.com/secure/developer?newapp=)
- add your application’s redirect URLs, which are the URL the user will be returned to after successful authentication. If you're testing locally you can write http://localhost:3000/callbacks/linkedin
- copy OAuth Credentials (Client ID and Secret) for your LinkedIn application
- make sure you check r_basicprofile and r_emailaddress under the Default Application Permissions
- log in to [your stormpath dashboard](https://api.stormpath.com/login) and visit the Directories section
- click on Create Directory and choose LinkedIn as the Directory Type. Name it and describe it however you want
- paste the copied OAuth Credentials that you copied when you created the LinkedIn application in the LinkedIn Client ID and secret fields
- paste the redirect URI that you also saved in your LinkedIn dashboard http://localhost:3000/callbacks/linkedin
- visit the Applications section and click on the application you're using
- click on Account Stores in the left sidebar and click on Add Account Store button
- after you add your newly created LinkedIn directory try starting up your server and visit /login. You should see the 1-click LinkedIn login button

## Migrate Devise Account information to Stormpath

If you already have a Rails application that uses devise and need to transfer all users, accounts, or however you named your model there's a nifty
rake task that you can create in your codebase by running:

```ruby
rails generate stormpath:migration
```

This will create a rake task that has the most common use cases for transferring user data into Stormpath:

```
lib/tasks/stormpath.rake
```

When you're finished modifying the rake task (minimum required modification: `directory href` and `devise model` that holds the data)
execute it with:

```ruby
rake stormpath:migrate
```

## Development

### Prerequisites

If you wish to contribute to the gem, please follow these steps:

1. Create a Stormpath Application.
2. Export the following env variables:
  - STORMPATH_CLIENT_APIKEY_ID
  - STORMPATH_CLIENT_APIKEY_SECRET
3. Create a Directory and associate it to the app. Make it the default account and group store for the app.

### Specs

Clone the repo & install the dependencies with `bundle install`.
The suite is written with RSpec, so to run the specs you'll need to execute `rspec`
The suite uses the [VCR gem](https://github.com/vcr/vcr) to record all the HTTP requests. On first roll it records them and after that all of the tests use the recorded HTTP requests and run under 10 seconds.
