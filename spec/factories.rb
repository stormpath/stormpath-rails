FactoryGirl.define do
  factory :account, class: Stormpath::Resource::Account do
    sequence(:email) { |n| "dev-#{n}-#{Faker::Lorem.word}@testmail.stormpath.com" }
    password 'Password1337'
    given_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    username { "#{Faker::Internet.user_name}_#{Faker::Internet.user_name}" }
    phone_number { Faker::PhoneNumber.cell_phone }
  end

  factory :account_without_username, class: Stormpath::Resource::Account do
    sequence(:email) { |n| "dev#{n}@testmail.stormpath.com" }
    password 'Password1337'
    given_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
  end

  factory :unverified_account, parent: :account do
    status 'UNVERIFIED'
  end

  factory :application, class: Stormpath::Resource::Application do
    sequence(:name) { |n| "rails-#{n}-#{Faker::Lorem.word}-application" }
    description 'rails test application'
  end

  factory :directory, class: Stormpath::Resource::Directory do
    sequence(:name) { |n| "rails-#{n}-#{Faker::Lorem.word}-directory" }
    description 'rails test directory'
  end

  factory :organization, class: Stormpath::Resource::Organization do
    sequence(:name) { |n| "rails-org-#{n}-#{Faker::Lorem.word}" }
    sequence(:name_key) { |n| "rails-org-#{n}-#{Faker::Lorem.word}" }
  end
end
