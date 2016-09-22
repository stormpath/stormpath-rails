.. _password_reset:


Password Reset
==============
#TODO: VERIFY EMAIL PAGE
Stormpath provides a self-service password reset flow for your users, allowing
them to request a link that lets them reset their password.  This is a very
secure feature and we highly suggest it for your application.


Enable the Workflow
-------------------

To use the password reset workflow, you need to enable it on the directory
that your application is using.  Login to the `Stormpath Admin Console`_ and
find your directory, then navigate to the workflows section of that directory.

Enable the password reset email if it is disabled.

You should also set the **Link Base Url** to be the following URL if you want the password reset form to be hosted on your domain:

 .. code-block:: sh

    http://localhost:3000/change

You can leave the default URL if you want the user to be redirected to the Stormpath password reset page with the reset form: ``https://api.stormpath.com/passwordReset``


Adjust Workflow in Config File
------------------------------

Make sure that you enable the workflow in your ``stormpath.yml`` configuration file

.. code-block:: ruby

    web:
      forgotPassword:
        enabled: true
        uri: "/forgot"
        view: "stormpath/rails/forgot_password/new"
        nextUri: "/login?status=forgot"
      changePassword:
        enabled: true
        autoLogin: false
        uri: "/change" # make sure the URI matches the one you stored in the Stormpath dashboard as the Link Base Url
        nextUri: "/login?status=reset"
        view: "stormpath/rails/change_password/new"
        errorUri: "/forgot?status=invalid_sptoken"


You may also change the URLs of the pages in this workflow, as well as the redirect URLs that we use during the workflow.
If so, just make sure that you apply the changes to the **Link Base Url** in the Stormpath dashboard, and restart your server.

Using the Workflow
------------------

After enabling the workflow, restart your Rails application.  You can now
complete a password reset workflow by doing the following steps:

* The login form at ``/login`` will show a "Forgot Password?" link.
* Clicking that link will take you to ``/forgot``, where you can ask for a password reset email
* After you receive the email, clicking on the link will take you to ``/change``
* You'll see a form that allows you to change your password
* After changing your password, you are taken to the login form



Auto Login
----------

Our gem implements the most secure workflow by default: the user must
request a password reset link, then login again after changing their password.
We recommend these settings for security purposes, but if you wish to automatically
log the user in after they reset their password you can enable that functionality
with this option:

 .. code-block:: ruby

      web:
        changePassword:
          autoLogin: false


.. _Stormpath Admin Console: https://api.stormpath.com
