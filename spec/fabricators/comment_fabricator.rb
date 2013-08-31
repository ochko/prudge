Fabricator(:comment) do
  user
  topic(fabricator: :post)
  text {Faker::Lorem.paragraph}
end
