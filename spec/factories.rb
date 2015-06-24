FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email 'jlc@example.com'
    password 'Password1337'
    given_name 'jean luc'
    surname 'picard'
  end
end
