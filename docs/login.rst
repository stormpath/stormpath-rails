.. _login:


Login
=====

By default this gem will serve an HTML login page at ``/login``.  You can
change this URI with the ``web.login.uri`` option.  You can disable this feature
entirely by setting ``web.login.enabled`` to ``false``.

To view the default page in your example application, navigate to this URL:

http://localhost:3000/login

If the login attempt is successful, we will send the user to the Next URI and
create the proper session cookies.


Next URI
--------

The form will render with two fields for login and password, and this form
will be posted to ``/login``.  If login is successful, we will redirect the user
to ``/``.  If you wish to change this, use the ``nextUri`` config option::

.. code-block:: ruby

      web:
        login:
          enabled: true,
          nextUri: "/dashboard"


Form Customization
------------------

The label and placeholder values can be changed by modifying the login form
field configuration:

.. code-block:: ruby

    web:
      login:
        form:
          fields:
            login:
              label: 'Your Username or Email',
              placeholder: 'email@trustyapp.com'
            password:
              label: 'Your super-secure PAssw0rd!'


Controller private & helper methods
-----------------------------------

The Application Controller gets the ``Stormpath::Rails::Controller`` module included by default. The module provides 4 private controller methods:

- ``current_account`` - get the current account
- ``signed_in?`` - check if the user is signed in.
- ``require_authentication!`` - a before action to stop unauthenticated access.
- ``require_no_authentication!`` - a before action to stop authenticated access (a logged in user shouldn't be able to see the login form).

By default, the ``current_account`` and ``signed_in?`` are marked as helper_methods and you can use them in your views.

If you wish to add these methods to a controller that doesn't inherit from the ApplicationController, just include the ``Stormpath::Rails::Controller`` module in that controller as well.


.. _json_login_api:

JSON Login API
--------------

If you want to make a login attempt from a front-end application (Angular, React),
simply post a JSON body to the ``/login`` endpoint, with the following format::

    {
      "login": "foo@bar.com",
      "password": "myPassword"
    }

If the login attempt is successful, you will receive a 200 OK response and the
session cookies will be set on the response.  If there is an error we will
send a 400 status with an error message in the body.

If you make a GET request to the login endpoint, with ``Accept:
application/json``, we will send you a JSON view model that describes the login
form and the social account stores that are mapped to your Stormpath
Application.  Here is an example view model that shows you an application that
has a default login form, and a mapped Google directory:

.. code-block:: javascript

  {
    "accountStores": [
      {
        "name": "stormpath-rails google",
        "href": "https://api.stormpath.com/v1/directories/gc0Ty90yXXk8ifd2QPwt",
        "provider": {
          "providerId": "google",
          "href": "https://api.stormpath.com/v1/directories/gc0Ty90yXXk8ifd2QPwt/provider",
          "clientId": "422132428-9auxxujR9uku8I5au.apps.googleusercontent.com",
          "scope": "email profile"
        }
      }
    ],
    "form": {
      "fields": [
        {
          "label": "Username or Email",
          "placeholder": "Username or Email",
          "required": true,
          "type": "text",
          "name": "login"
        },
        {
          "label": "Password",
          "placeholder": "Password",
          "required": true,
          "type": "password",
          "name": "password"
        }
      ]
    }
  }


Overriding Login
----------------

Controllers
...........

Since Stormpath controllers are highly configurable, they have lots of configuration code and are not written in a traditional way.

A LoginController would usually have two actions - new & create, however in Stormpath-Rails they are separated into two single action controllers - ``Stormpath::Rails::Login::NewController`` and ``Stormpath::Rails::Login::CreateController``.
They both respond to a ``call`` method (action).

To override a Stormpath controller, first you need to subclass it:

.. code-block:: ruby

    class CreateSessionController < Stormpath::Rails::Login::CreateController
    end


and update the routes to point to your new controller:

.. code-block:: ruby

    Rails.application.routes.draw do
      stormpath_rails_routes(actions: {
        'login#create' => 'create_session#call'
      })
    end


Routes
------

To override routes (while using Stormpath default controllers), please use the configuration file ``config/stormpath.yml`` and override them there.
As usual, to see what the routes are, run *rake routes*.

Views
-----

You can use the Stormpath views generator to copy the default views to your application for modification:

.. code-block:: ruby

    rails generate stormpath:views


which generates these files::

    stormpath/rails/layouts/stormpath.html.erb

    stormpath/rails/login/new.html.erb
    stormpath/rails/login/_form.html.erb

    stormpath/rails/register/new.html.erb
    stormpath/rails/register/_form.html.erb

    stormpath/rails/change_password/new.html.erb

    stormpath/rails/forgot_password/new.html.erb

    stormpath/rails/shared/_input.html.erb

    stormpath/rails/verify_email/new.html.erb


Using ID Site
----------------------------------------------------------------------

Stormpath provides a hosted login application, known as ID Site.  This feature
allows you to redirect the user to our hosted application.  When the user
authenticates, they will be redirected back to your application with an identity
assertion.

This feature is useful if you don't want to modify your application to serve
web pages or single page apps, and would rather have that hosted somewhere else.

ID site looks like this:

.. image:: /_static/id-site-login.png

For more information about how to use and customize the ID site, please see
this documentation:

http://docs.stormpath.com/guides/using-id-site/

ID Site Configuration
.....................

If you wish to use the ID Site feature, you will need to log in to the
`Stormpath Admin Console`_ and configure the settings.  You need to change the
**Authorized Redirect Uri** setting and set it to
``http://localhost:3000/id_site_result``

Then you want to enable ID Site in your rails stormpath configuration:

.. code-block:: ruby

      web:
        idSite:
          enabled: true,
          uri: '/id_site_result'    # default setting
          nextUri: '/'            # default setting


When ID Site is enabled, any request for ``/login`` or ``/register`` will cause a
redirect to ID Site.  When the user is finished at ID Site they will be
redirected to `/idSiteResult` on your application.  Our gem will handle
this request, and then redirect the user to the ``nextUri``.


.. _Stormpath Admin Console: https://api.stormpath.com
