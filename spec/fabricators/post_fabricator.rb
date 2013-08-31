Fabricator(:post) do |c|
  author(fabricator: :user)
  category 'blog'
  title {Faker::Lorem.sentence}
  body  {Faker::Lorem.paragraphs}
end
