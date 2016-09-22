.. _logout:


Logout
======

If you are using browser-based sessions, you'll need a way for the user to
logout and destroy their session cookies.

By default this library will automatically provide a POST route at ``/logout``.
Simply make a POST request to this URL and the session cookies will be
destroyed.

On a Rails application, this can usually be achieved with the following snippet in a view file:

.. code-block:: ruby

    <% if signed_in? %>
      <p>Logged in as: <%= current_account.given_name %></p>
      <%= link_to "Log out", logout_path, method: :post %>
    <% end %>


Configuration Options
---------------------

If you wish to change the logout URI or the redirect url, you can provide the
following configuration:

.. code-block:: ruby

    web:
      logout:
        enabled: true,
        uri: '/log-me-out',
        nextUri: '/goodbye'


Overriding Logout
-----------------

Controllers
...........

Since Stormpath controllers are highly configurable, they have lots of configuration code and are not written in a traditional way.

Logging out users is usually done with just a destroy method in some kind of SessionController, but in Stormpath we strive for high configuration so we
are handling this with a LogoutController that has one method ``create`` which responds to the ``call`` method.

To override a Stormpath controller, first you need to subclass it:

.. code-block:: ruby

    class DestroySessionController < Stormpath::Rails::Logout::CreateController
    end


and update the routes to point to your new controller:

.. code-block:: ruby

    Rails.application.routes.draw do
      stormpath_rails_routes(actions: {
        'logout#create' => 'destroy_session#call'
      })
    end


Routes
------

To override routes (while using Stormpath default controllers), please use the configuration file ``config/stormpath.yml`` and override them there.
As usual, to see what the routes are, run *rake routes*.
