FactoryGirl.define do
  factory :user, class: Stormpath::Resource::Account do
    email 'jlc@example.com'
    password 'Password1337'
    given_name 'jean luc'
    surname 'picard'
  end
end
