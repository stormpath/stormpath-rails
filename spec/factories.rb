FactoryGirl.define do
  factory :user, class: Stormpath::Resource::Account do
    email { Faker::Internet.email }
    password 'Password1337'
    given_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    username { Faker::Internet.user_name }
  end

  factory :unverified_user, parent: :user do
    status 'UNVERIFIED'
  end
end
