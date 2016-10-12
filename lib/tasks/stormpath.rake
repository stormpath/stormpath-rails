namespace :stormpath do
  desc 'Migrate devise data to Stormpath'
  task migrate_devise: :environment do
    # application = Stormpath::Rails::Client.client.applications.create(name: 'Devise import', description: 'devise desc')
    # directory = Stormpath::Rails::Client.client.directories.create name: 'devise import', description: 'devise import'
    # Stormpath::Rails::Client.client.account_store_mappings.create({
    #   application: application,
    #   account_store: directory,
    #   list_index: 0,
    #   is_default_account_store: true,
    #   is_default_group_store: false
    #  })
    directory_href = 'https://api.stormpath.com/v1/directories/4BjHtySIVQ8iwz96rguEE1'
    directory = Stormpath::Rails::Client.client.directories.get(directory_href)

    User.all.find_each do |user|
      account = directory.accounts.create(
        { username: "rex#{user.id}",
          email: user.email,
          given_name: 'Captain',
          middle_name: '12345',
          surname: 'Rex',
          password: user.encrypted_password },
        password_format: 'mcf'
      )

      puts "#{user.email} migrated"

      # auth_request = Stormpath::Authentication::UsernamePasswordRequest.new account.username, 'NotSoSecureAreYou'
      # auth_result = application.authenticate_account auth_request

      #account.delete unless user == User.last
    end
  end
end
