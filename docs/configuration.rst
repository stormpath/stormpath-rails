.. _configuration:


Configuration
=============

This module provides several options that allow you to customize the authentication
features of your Rails application. We will cover the major options in this
section, and more specific options in later sections of this guide.

If you would like a list of all available options, please refer to the
`Web Configuration Defaults`_ file in the library. This YAML file has comments
which describe each option and the value represents the option default.


Environment Variables
---------------------

It is a best practice to store confidential information in environment
variables (*don't hard-code it into your application*). You should store your
confidential Stormpath information in environment variables.  You can do this
by running the following commands in the shell:

.. code-block:: bash

    export STORMPATH_CLIENT_APIKEY_ID=YOUR_ID_HERE
    export STORMPATH_CLIENT_APIKEY_SECRET=YOUR_SECRET_HERE
    export STORMPATH_APPLICATION_HREF=YOUR_APP_HREF

or by using any text editor and adding the environment variables to .bashrc (or .zshrc if you're using ohmyzsh)

.. note::
    If you're on Windows, the command you need to use to set environment
    variables is:

    .. code-block:: bash

        set STORMPATH_CLIENT_APIKEY_ID=YOUR_ID_HERE
        set STORMPATH_CLIENT_APIKEY_SECRET=YOUR_SECRET_HERE
        set STORMPATH_APPLICATION_HREF=YOUR_APP_HREF

The examples above show you the 3 mandatory settings you need to configure to
make stormpath-rails work.  These settings can be configured via environment
variables, or in a number of other ways.

.. note::

    If you're using Heroku you don't need to specify the credentials or
    your application -- these values will be automatically provided for you.

.. tip::

    You might also want to check out
    `autoenv <https://github.com/kennethreitz/autoenv>`_, a project that makes
    working with environment variables simpler for Linux/Mac/BSD users.


Default Features
----------------

When you add stormpath_rails_routes to your routes configuration file,
our module will automatically add the following routes to your application:

+--------------+-------------------------------------------------------------+---------------------------+
| URI          | Purpose                                                     | Documentation             |
+==============+=============================================================+===========================+
| /forgot      | Request a password reset link.                              | :ref:`password_reset`     |
+--------------+-------------------------------------------------------------+---------------------------+
| /login       | Login to your application with username and password.       | :ref:`login`              |
+--------------+-------------------------------------------------------------+---------------------------+
| /logout      | Accepts a POST request, and destroys the login session.     | :ref:`logout`             |
+--------------+-------------------------------------------------------------+---------------------------+
| /me          | Returns a JSON representation of the current user.          | :ref:`me_api`             |
+--------------+-------------------------------------------------------------+---------------------------+
| /oauth/token | Issue OAuth2 access and refresh tokens.                     | :ref:`authentication`     |
+--------------+-------------------------------------------------------------+---------------------------+
| /register    | Create an account within your application.                  | :ref:`registration`       |
+--------------+-------------------------------------------------------------+---------------------------+
| /reset       | Reset an account password, from a password reset link.      | :ref:`password_reset`     |
+--------------+-------------------------------------------------------------+---------------------------+
| /verify      | Verify a new account, from a email verification link.       | :ref:`email_verification` |
+--------------+-------------------------------------------------------------+---------------------------+

Each feature has its own options, please refer to the documentation of each
feature. If you want to disable specific features, continue to the next
section.

Disabling Features
------------------

We enable many features by default, but you might not want to use all of them.
For example, if you wanted to disable all the default features, you would use
this configuration:

 .. code-block:: yaml

    stormpath:
      web:
        login:
          enabled: false
        logout:
          enabled: false
        me:
          enabled: false
        oauth2:
          enabled: false
        register:
          enabled: false



Stormpath Client Options
------------------------

By using this gem you are able to instantiate a client object.
The Stormpath client is responsible for communicating with the Stormpath REST
API and is provided by the `Stormpath Ruby SDK`_. If you would like to work directly with the client in your Rails application,
you can fetch it from the app object like this:

 .. code-block:: ruby

    client = Stormpath::Rails::Client.client

The `client` object is also highly configurable through the use of the Ruby SDK. You can set how it is instantiated, custom caching options and the base URL for your enterprise application.
For more detail concerning the `client` object, please visit the `Ruby SDK Documentation`_.

Stormpath Application
---------------------

When you configured Stormpath, you specified the Stormpath Application that you
want to use (you did this by providing the HREF of the application).  This gem
will fetch the application and use it to perform all login, registration,
verification and password reset functions.

The Stormpath Application allows you to do a lot of other work, such as manually
creating accounts and modifying your OAuth policy - plus much more!  If you want
to work with the Stormpath Application, you can reference its object like this:

.. code-block:: ruby

    client = Stormpath::Rails::Client.client
    application = client.applications.get(app_href)
    application.accounts.create(account_attributes)

where *app_href* is your application URL from Stormpath that you stored in a environment variable.

.. _Web Configuration Defaults: https://github.com/stormpath/stormpath-rails/blob/master/lib/generators/stormpath/install/templates/default_config.yml
.. _Stormpath applications: https://api.stormpath.com/v#!applications
.. _Stormpath dashboard: https://api.stormpath.com/ui/dashboard
.. _Stormpath Ruby SDK: https://github.com/stormpath/stormpath-sdk-ruby
.. _Ruby SDK Documentation: https://docs.stormpath.com/ruby/product-guide/latest/configuration.html
