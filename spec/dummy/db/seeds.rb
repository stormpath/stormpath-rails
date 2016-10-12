10.times do |i|
  User.create(email: "example-#{i}-user@example.com", password: 'NotSoSecureAreYou')
end
