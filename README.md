[![Build Status](https://secure.travis-ci.org/stormpath/stormpath-rails.png)](http://travis-ci.org/stormpath/stormpath-rails)
[![Code Climate](https://codeclimate.com/github/stormpath/stormpath-rails.png)](https://codeclimate.com/github/stormpath/stormpath-rails)
# Stormpath Rails Gem

Stormpath is the first easy, secure user management and authentication service for developers.
This is the Rails gem to ease integration of its features with any Rails-based application.

## Setup

1. Install the <code>stormpath-rails</code> gem, either via the command line:

    ```
    $ gem install stormpath-rails
    ```

  or adding the gem to your [Bundler][bundler] Gemspec:

    ```
    gem 'stormpath-rails'
    ```

  or any other preferred dependency.

2. Create a [Stormpath][stormpath] developer account and [create your API Keys][create-api-keys]
  downloading the <code>apiKey.properties</code> file into a <code>.stormpath</code>
  folder under your local home directory. So that the Rails gem knows where to find this file,
  add an environment variable called STORMPATH\_API\_KEY\_FILE\_LOCATION whose value is the full
  path to this new .properties file:

    ```sh
    export STORMPATH_API_KEY_FILE_LOCATION="/Users/john/.stormpath/apiKey.properties"
    ```

3. Create an application and a directory to store your users' accounts through the
  [Stormpath Admin][stormpath-admin] interface. Make sure to add the newly-created
  directory as a Login Source for your newly-created Application.

4. Through the [Stormpath Admin][stormpath-admin] interface, note your application's REST URL.
  You'll want to create an environment variable called STORMPATH\_APPLICATION\_URL whose value
  is this URL.

5. Generate and run migration, if you're on ActiveRecord. Skip this step for Mongoid.
  ```sh
  rails g stormpath:rails:migration user
  rake db:migrate
  ```

6. Update your model file.
  ```ruby
  class User < ActiveRecord:Base
    include Stormpath::Rails::Account
  end
  ```

## Testing

To run the test suite, simple run:

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
