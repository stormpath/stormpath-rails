FactoryGirl.define do
  factory :account, class: Stormpath::Resource::Account do
    sequence(:email) { |n| "dev#{n}@example.com" }
    password 'Password1337'
    given_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    username { Faker::Internet.user_name }
  end

  factory :unverified_account, parent: :account do
    status 'UNVERIFIED'
  end
end
