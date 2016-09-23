.. _user_data:

User Data
=========


current_account
---------------

When writing your own controller methods, you will likely want to use
the account object. There are two primary ways to do this: with the `current_account`
helper method, and with our other authentication helper method.

Resolving The Current User(Account)
....................................

In this situation, we have a home page which needs to render itself differently
if the user is logged in.  In this scenario, we don't *require* authentication,
but we need to know if the user is logged in.  In this case we use the
``current_account`` method:

  .. code-block:: ruby

    // Basic controller method example

      if current_account do
        render text: "Hello #{current_account.email}"
      else
        render text: 'Not logged in'
      end


Forcing Authentication
......................

If you require authentication for a route, you should use one of the
authentication helper methods that are documented in the
:ref:`authentication` section.

When you use these middlewares, we won't call your controller method unless the
user is logged in.  If the user is not logged in, we bypass your middleware and
redirect the user to the login page for HTML requests, or send a 401 error for
JSON requests.

For example, if you've defined a simple view that should simply display a user's
email address, we can use the ``require_authentication!`` method to require them to be
logged in in order to have access to the show view:

  .. code-block:: ruby

      class ProfilesController < ApplicationController
        before_action :require_authentication!

        def show
        end
      end


Modifying The Account
......................

The ``current_account`` context allows you to directly interact with the current
``account`` object.  This means you can perform *any* action on the ``account`` object
directly.

Perhaps you want to change a accounts's ``given_name`` (*first name*).  You could
easily accomplish this with the following code:

.. code-block:: ruby

    current_account.given_name = 'Clark';
    if current_account.save
      puts('Successfully updated account!')
    else
      puts('There was an error processing your request')
    end

As you can see above, you can directly modify ``account`` attributes, then
save any changes by running ``current_account.save``.


Custom Data
-----------

In addition to managing basic user fields, Stormpath also allows you to store
up to 10MB of JSON information with each user account!

Instead of defining a database table for users, and another database table for
user profile information -- with Stormpath, you don't need either!

Let's take a look at how easy it is to store custom data on a ``user``
model:

.. code-block:: ruby

    // You can add fields
    current_account.custom_data[:rank] = 'General'
    current_account.custom_data[:experience] = {'speed': 100, 'precision': 68};
    current_account.custom_data.save

    // And delete fields

    current_account.custom_data[:rank].delete

    // And then save it all at once

    if current_account.custom_data.save
      puts('Successfully updated custom data account!')
    else
      puts('There was an error processing your request')
    end

As you can see above -- storing custom information on a ``user`` account is
extremely simple!


Automatic Expansion
-------------------

In Stormpath, all objects are connected in a graph.  You
have to expand a resource to get its child resources, and this
is an asynchronous operation.  We can pre-fetch the expanded
user data for you.  Simply pass the `Expansion` resource while fetching the account:

.. code-block:: ruby

    client.accounts.get(current_account.href, Stormpath::Resource::Expansion.new('directory'))


Our gem will pre-expand those resources for you, so that
they are statically available inside your methods.

Without enabling this expansion, the response would only contain
an object which has an href to the resource, that would look
like this:

.. code-block:: javascript

    {
      href: 'http://api.stormpath.com/v1/accounts/avIu4NrfCk49uzhfCk/customData'
    }

.. note::

 Custom data is expanded automatically, but you can disable this

You can expand any of these *"linked resources"*:

- ``apiKeys`` - A user's API keys.
- ``customData`` - A user's custom data.
- ``directory`` - A user's directory data.
- ``groups`` - A user's group data.
- ``groupMemberships`` - A user's group membership data.
- ``providerData`` - A user's provider data (*for social login providers*).
- ``tenant`` - A user's tenant data.

.. _me_api:

Current User JSON API
---------------------

If you are working with a front-end application, you can make a request to the
``/me`` URL to get a JSON representation of the account that is currently
logged in.  If the user is not logged in, this endpoint will return a 401
response.

The response from the endpoint looks like this:

.. code-block:: javascript

  {
    "account": {
      "href": "https://api.stormpath.com/v1/accounts/4WvCtY0oCRDzQdYH3Q0qjz",
      "username": "foobar",
      "email": "foo@example.com",
      "givenName": "Foo",
      "middleName": null,
      "surname": "Bar",
      "fullName": "Foo Bar",
      "status": "ENABLED",
      "createdAt": "2015-10-13T20:54:22.215Z",
      "modifiedAt": "2016-03-17T16:40:17.631Z"
    }
  }

By default we don't expand any data on the account, for security purposes.  But
you can opt-in to account expansions with the following configuration in the *stormpath.yml*:

.. code-block:: ruby

    me:
      enabled: true
      uri: "/me"
      expand:
        apiKeys: true
        applications: true
        customData: true
        directory: true
        groupMemberships: true
        groups: true
        providerData: true
        tenant: true

If you wish to disable the ``/me`` route entirely, you can do that as well:

.. code-block:: ruby

    me:
      enabled: false


.. _Account Object: https://docs.stormpath.com/ruby/quickstart/
.. _Stormpath Ruby SDK: https://github.com/stormpath/stormpath-sdk-ruby
