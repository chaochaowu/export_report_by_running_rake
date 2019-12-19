20.times do
  User.create(email: Faker::Internet.unique.email, password: Faker::Internet.password)
end