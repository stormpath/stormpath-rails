.. _devise_import:


Import Data from Devise
=======================

If you already have a Rails application that uses devise and need to transfer all users, accounts, or however you named your model there's a nifty rake task that you can create in your codebase by running:

.. code-block:: sh

    rails generate stormpath:migration

This will create a rake task that has the most common use cases for transferring user data into Stormpath that you can configure:

.. code-block:: sh

  lib/tasks/stormpath.rake


Default Configuration
----------------------

This configuration is for the simplest migrations, where the goal is to just transfer all account information from devise's User model into one existing directory:

.. code-block:: ruby

  namespace :stormpath do
    desc 'Migrate devise data to Stormpath'
    task migrate: :environment do
      directory_href = 'https://api.stormpath.com/v1/directories/4BjHtySIVQ8iwz96rguEE1'
      directory = Stormpath::Rails::Client.client.directories.get(directory_href)

      User.all.find_each do |user|
        directory.accounts.create(
          { username: "rex#{user.id}",
            email: user.email,
            given_name: 'Captain',
            middle_name: '12345',
            surname: 'Rex',
            password: user.encrypted_password },
          password_format: 'mcf'
        )
        puts "#{user.email} migrated to Stormpath directory: #{directory.name}"
      end
    end
  end

This is the minimal configuration needed to execute the migration successfully. All you need to do is set your `directory_href` which you can find by logging into the `Stormpath Admin Console`_ and viewing the directory you want to transfer your users into.
Of course, make sure you use the correct name of the model for your users, accounts, members etc.


New Application and Directory
------------------------------

You can also create a new application and directory in which you'll be storing your accounts, or, depending on account attributes, you could modify the script and migrate some accounts to one directory, and the rest to another.

.. code-block:: ruby

  application = Stormpath::Rails::Client.client.applications.create(name: 'Devise import',
                                                                    description: 'Devise')

  directory = Stormpath::Rails::Client.client.directories.create(name: 'devise import',
                                                                 description: 'devise import'

  # =>  Map the two together
  Stormpath::Rails::Client.client.account_store_mappings.create(
    application: application,
    account_store: directory,
    list_index: 0,
    is_default_account_store: true,
    is_default_group_store: false
  )


Custom Account Data
--------------------

If you have any custom user data that you need to keep stored on Stormpath, here's an example of how you can do that too:

.. code-block:: ruby

  User.all.find_each do |user|
    account = directory.accounts.create(
      { username: "rex{user.id}",
        email: user.email,
        given_name: 'Jean-Luc',
        surname: 'Picard',
        password: user.encrypted_password,
        custom_data: {
          rank: 'Captain',
          favorite_drink: 'Earl Grey Tea'
        } },
      password_format: 'mcf'
    )
    puts "#{user.email} with custom data #{account.custom_data['favorite_drink']} migrated."
  end

For more information on account management, visit the `Account Management Chapter`_ or `Multitenancy Chapter`_.

Migration Process
---------------------

When you're finished modifying the rake task execute it with:

.. code-block:: sh

  rake stormpath:migrate


.. _Stormpath Admin Console: https://api.stormpath.com/login
.. _Account Management Chapter: https://docs.stormpath.com/ruby/product-guide/latest/accnt_mgmt.html
.. _Multitenancy Chapter: https://docs.stormpath.com/ruby/product-guide/latest/multitenancy.html
