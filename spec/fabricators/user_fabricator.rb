Fabricator(:user) do
  login { sequence(:login) { |i| i.to_s + Faker::Internet.user_name  } }
  email { sequence(:email) { |i| i.to_s + Faker::Internet.email } }
  password '123password'
  password_confirmation '123password'
end

Fabricator(:coder, from: :user) do
  admin false
  judge false
end

Fabricator(:admin, from: :user) do
  admin true
  judge false
end

Fabricator(:judge, from: :user) do
  admin false
  judge true
end

Fabricator(:superuser, from: :user) do
  admin true
  judge true
end
