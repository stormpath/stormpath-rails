[![Build Status](https://secure.travis-ci.org/stormpath/stormpath-rails.png)](http://travis-ci.org/stormpath/stormpath-rails)
[![Code Climate](https://codeclimate.com/github/stormpath/stormpath-rails.png)](https://codeclimate.com/github/stormpath/stormpath-rails)
# Stormpath Rails Gem

Stormpath is the first easy, secure user management and authentication service for developers.
This is the Rails gem to ease integration of its features with any Rails-based application.

## Assumptions

The bulk of this guide assumes that you are creating a new Rails application from scratch and want to user Stormpath for use management out of the box. If you have an existing application into which you want to integrate Stormpath, and that application already has the notion of a user in it, skip to the "[Sign Up For A Stormpath Account](#signup)" section.

## Setup

1. Navigate to where you'd like to start your new app.

2. Use rails to create a new application and cd into it:
  
    ```
    rails new myApp
    cd myApp
    ```

3. Initialize your application's database and create a "User" object

    ```
    rake db:create
    rails generate scaffold User username:string email:string
    rake db:migrate
    ```

4. Delete the public HTML file (public/index.html) and modify your "routes.rb" file (app/config) to point to your user controller:

  ```
  root :to => 'users#index'
  ```

## <a name="signup"></a>Sign Up For A Stormpath Account

1. Create a [Stormpath][stormpath] developer account and [create your API Keys][create-api-keys]
  downloading the "apiKey.properties" file into a ".stormpath"
  folder under your local home directory. So that the Rails gem knows where to find this file,
  add an environment variable called `STORMPATH_API_KEY_FILE_LOCATION` whose value is the full
  path to this new .properties file:

    ```sh
    export STORMPATH_API_KEY_FILE_LOCATION="/Users/john/.stormpath/apiKey.properties"
    ```

2. Within Stormpath's Admin Console, create an application  and a directory to store your users' accounts through the [Stormpath Admin][stormpath-admin] interface. Make sure to add the newly-created directory as a Login Source for your newly-created application.

3. Through the [Stormpath Admin][stormpath-admin] interface, note your application's REST URL.
  You'll want to create an environment variable called STORMPATH\_APPLICATION\_URL whose value
  is this URL.

## Integrating Stormpath Rails

1. Install the <code>stormpath-rails</code> gem, either via the command line:

    ```
    $ gem install stormpath-rails --pre
    ```

  or adding the gem to your [Bundler][bundler] Gemspec...

    ```
    gem 'stormpath-rails', '>= 1'
    ```

  ...and then run `bundle install`.

5. Generate and run the migration script. Skip this step if you've configured your app to use Mongoid instead of ActiveRecord.
  
  ```sh
  rails g stormpath:rails:migration user
  rake db:migrate
  ```

6. Update your "user" model file under app/models/ as follows:.
  
  ```ruby
  require 'stormpath-rails'
  class User < ActiveRecord::Base
      include Stormpath::Rails::Account
  end
  ```

7. Modify any views that interact with the user controller and model (e.g., create, edit, etc.) to use the specific fields specific to [Stormpath's notion of a user](http://stormpath.com/docs/ruby/product-guide#!Accounts):

    * username
    * email
    * given_name
    * middle_name
    * surname
    * password

  For example, if you have a form for your editing your user object, you'll need to change the view (e.g., app/views/users/edit.html.erb) to include something like the following:

        <div class="field">
          <%= f.label :username %><br />
          <%= f.text_field :username %>
        </div>
        <div class="field">
          <%= f.label :email %><br />
          <%= f.text_field :email %>
        </div>
         <div class="field">
          <%= f.label :given_name %><br />
          <%= f.text_field :given_name %>
        </div>
         <div class="field">
          <%= f.label :middle_name %><br />
          <%= f.text_field :middle_name %>
        </div>
         <div class="field">
          <%= f.label :surname %><br />
          <%= f.text_field :surname %>
        </div>  
        <div class="field">
          <%= f.label :password %><br />
          <%= f.text_field :password %>
        </div>
        <div class="actions">
          <%= f.submit %>
        </div>

Now, start your local server with `rails s` and try to create a user (e.g., http://0.0.0.0:3000/users/new). You'll need to create a user in your application before you can authenticate it via your Ruby application. 

Voila! Your application is now connected to Stormpath.

## Testing The Stormpath-Rails Gem

To run the test suite on the gem itself (and not your integration), simple run:

```sh
$ rake spec
```

Note that this will make requests to the Stormpath API; you'll need to have set
environment variables enabling the client to interact with your Stormpath
account. You'll also need to have environment variables set that will enable
the client to interact with a test directory and application.

The test run will also generate a code-coverage report, viewable in the
coverage subdirectory.

## Contributing

You can make your own contributions by forking the <code>development</code>
branch, making your changes, and issuing pull-requests on the
<code>development</code> branch.

## Building the Gem

To build and install the development branch yourself from the latest source:

```
$ git clone git@github.com:stormpath/stormpath-rails.git
$ cd stormpath-rails
$ rake gem
$ gem install pkg/stormpath-rails-{version}.gem
```

## TODO

+ Automatic directory layout (test, development, production) creation
+ Preventive validation to not send invalid data to stormpath.
+ Preventive validation to not send invalid data to stormpath.
+ Solve n+1 request problem when requesting account collection.

## Copyright & Licensing

Copyright &copy; 2013 Stormpath, Inc. and contributors.

This project is licensed under the [Apache 2.0 Open Source License](http://www.apache.org/licenses/LICENSE-2.0).

For additional information, please see the full [Project Documentation](https://www.stormpath.com/docs/ruby/product-guide).

  [bundler]: http://gembundler.com/
  [stormpath]: http://stormpath.com/
  [create-api-keys]: http://www.stormpath.com/docs/ruby/product-guide#AssignAPIkeys
  [stormpath_bootstrap]: https://github.com/stormpath/stormpath-sdk-ruby/wiki/Bootstrapping-Stormpath
  [stormpath-admin]: https://api.stormpath.com/login
