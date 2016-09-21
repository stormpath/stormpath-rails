.. _quickstart:


Quickstart
=============================

This section walks you through the basic setup for Stormpath Rails gem, by the end
of this page you'll have setup the login and registration features for your
Rails application!

Create a Stormpath Account
--------------------------

Now that you've decided to use Stormpath, the first thing you'll want to do is
create a new Stormpath account: https://api.stormpath.com/register


Create an API Key Pair
----------------------

Once you've created a new account you need to create a new API key pair. A new
API key pair is easily created by logging into your dashboard and clicking the
"Create an API Key" button. This will generate a new API key for you, and
prompt you to download your key pair.

.. note::
    Please keep the API key pair file you just downloaded safe!  These two keys
    allow you to make Stormpath API requests, and should be properly protected,
    backed up, etc.

Once you've downloaded your `apiKey.properties` file, save it and be sure to set up the following environment variables:

 - STORMPATH_API_KEY_ID
 - STORMPATH_API_KEY_SECRET

Environment variables should be set up in you .bashrc file (or .zshrc if you use myzsh).

Example setup:

.. code-block:: sh

    export STORMPATH_API_KEY_ID=6U4HZMHGVHN0U765BGW
    export STORMPATH_API_KEY_SECRET=0e0TuVZKYiPiLTDLNnswEwpPpa5nPv

Find Your Stormpath Application
-------------------------------

All new Stormpath Tenants will have a Stormpath Application, called
"My Application". You'll generally want one application per project, and we can
use this default application to get started.

An application has a HREF, and it looks like this:

.. code-block:: sh

    https://api.stormpath.com/v1/applications/24kkU5XOz4tQlZ7sBtPUN6

From inside the `Admin Console`_, you can find the HREF by navigating to the
Application in the Application's list.

To learn more about Stormpath Applications, please see the
`Application Resource`_ and
`Setting up Development and Production Environments`_

.. note::
    Your default Application will also have a directory mapped to it. The
    Directory is where Stormpath stores accounts. To learn more, please see
    `Directory Resource`_ and `Modeling Your User Base`_.

- Make sure your application has a default account directory.

Now that you have your application HREF, make sure to set up another environment variable:

.. code-block:: sh

    export STORMPATH_APPLICATION_URL=https://api.stormpath.com/v1/applications/24kkU5XOz4tQlZ7sBtPUN6


You're ready to bundle Stormpath Rails gem into your project!

Install the Gem
-------------------

Now that you've got a Stormpath account all setup and ready to go, all that's
left to do before we can dive into the code is install the gem.

Stormpath Rails officially supports Ruby versions over 2.1.0 and Rails over 4.0.

Add the stormpath-rails integration gem to your Gemfile.

Stormpath is currently in beta so it is necessary to include the gem version:

.. code-block:: ruby

    gem 'stormpath-rails', '~> 2.0.0'

Bundle the Gemfile

.. code-block:: ruby

    bundle install

Run the generator to insert the config yaml file and the neccessary controller module.

.. code-block:: sh

    rails generate stormpath:install


Routes configuration
----------------------------

Make sure that you have the `root_path` defined in your rails `routes.rb`

Then, add `stormpath_rails_routes` to your routes.rb file.

.. code-block:: ruby

    Rails.application.routes.draw do
      root 'home#index'
      stormpath_rails_routes
      ...
    end


Start your server
----------------------------

Yes, that's it.

With this minimal configuration, our library will do the following:

- Fetch your Stormpath Application and all the data about its configuration and
  account stores.

- Attach the default features to your Rails application, such as the
  login page and registration page.

- Hold any requests that require authentication, until Stormpath is ready.

That's it, you're ready to go! Try navigating to these URLs in your application:

- http://localhost:3000/login
- http://localhost:3000/register

You should be able to register for an account and log in. The newly created
account will be placed in the directory that is mapped to "My Application".

.. note::

    By default, we don't require email verification for new accounts, but we
    highly recommend you use this workflow. You can enable email verification
    by logging into the `Admin Console`_ and going to the the Workflows tab
    for the directory of your Stormpath Application.

There are many more features than login and registration, please continue to the
next section to learn more!


Example Applications
--------------------

Looking for some example applications?  We provide the following examples
applications to get you up and running quickly.  They show you how to setup
Stormpath, and implement a profile page for the logged-in user:

- `Stormpath-Rails Sample Project`_

- `Stormpath Angular + Rails Sample Project`_

.. _Admin Console: https://api.stormpath.com/login
.. _Application Resource: https://docs.stormpath.com/rest/product-guide/latest/reference.html#application
.. _Active Directory: http://en.wikipedia.org/wiki/Active_Directory
.. _Directory Resource: https://docs.stormpath.com/rest/product-guide/latest/reference.html#directory
.. _Stormpath-Rails Sample Project: https://github.com/stormpath/stormpath-rails-sample
.. _LDAP: http://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
.. _Modeling Your User Base: https://docs.stormpath.com/rest/product-guide/latest/accnt_mgmt.html#modeling-your-user-base
.. _Setting up Development and Production Environments: https://docs.stormpath.com/guides/dev-test-prod-environments/
.. _Stormpath Angular + Rails Sample Project: https://github.com/stormpath/stormpath-angular-rails-sample
