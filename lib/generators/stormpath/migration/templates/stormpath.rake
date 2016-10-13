namespace :stormpath do
  desc 'Migrate devise data to Stormpath'
  task migrate: :environment do
    # This is the migration script used for transferring users from your database to Stormpath.
    # You can tailor it by your needs from the examples below.
    # If you need different or additional specifications you can read our documentation:
    # https://docs.stormpath.com/rest/product-guide/latest/accnt_mgmt.html

    # ==============================================================
    # Use an exhisting directory for storing your users
    # Paste your directory href below.
    # ==============================================================

    directory_href = 'https://api.stormpath.com/v1/directories/4BjHtySIVQ8iwz96rguEE1'
    directory = Stormpath::Rails::Client.client.directories.get(directory_href)

    # ==============================================================
    # Migrate the users - this is the default approach (DEVISE) to migrating users from your db
    # to Stormpath without the registration workflow.
    # Hovewer, you can change it depending on your needs.
    # https://docs.stormpath.com/rest/product-guide/latest/accnt_mgmt.html#importing-accounts
    # ==============================================================

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

    # ==============================================================
    # Create a new application in which you'll be storing your users
    # ==============================================================

    # application = Stormpath::Rails::Client.client.applications.create(name: 'Devise import',
    #                                                                   description: 'Devise')
    # directory = Stormpath::Rails::Client.client.directories.create(name: 'devise import',
    #                                                                description: 'devise import'
    # =>  Map the two together
    # Stormpath::Rails::Client.client.account_store_mappings.create(
    #   application: application,
    #   account_store: directory,
    #   list_index: 0,
    #   is_default_account_store: true,
    #   is_default_group_store: false
    # )

    # ==============================================================
    # Store Additional User Information as Custom Data
    # https://docs.stormpath.com/rest/product-guide/latest/accnt_mgmt.html#how-to-store-additional-user-information-as-custom-data
    # ==============================================================

    # User.all.find_each do |user|
    #   account = directory.accounts.create(
    #     { username: "rex#{user.id}",
    #       email: user.email,
    #       given_name: 'Jean-Luc',
    #       surname: 'Picard',
    #       password: user.encrypted_password,
    #       custom_data: {
    #         rank: 'Captain',
    #         favorite_drink: 'Earl Grey Tea'
    #       } },
    #     password_format: 'mcf'
    #   )
    #   puts "#{user.email} with custom data #{account.custom_data['favorite_drink']} migrated."
    # end
  end
end
