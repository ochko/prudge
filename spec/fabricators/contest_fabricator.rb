Fabricator(:contest) do |c|
  c.name        { Faker::Company.catch_phrase }
  c.description { Faker::Lorem.paragraph }
  c.start       Time.now + 1.hour
  c.end         Time.now + 3.hours
end

Fabricator(:ongoing_contest, from: :contest) do |c|
  c.start       Time.now - 1.hour
  c.end         Time.now + 2.hour
end

Fabricator(:finished_contest, from: :contest) do |c|
  c.start       Time.now - 3.hours
  c.end         Time.now - 1.hour
end

Fabricator(:upcoming_contest, from: :contest) do |c|
  c.start       Time.now + 1.hours
  c.end         Time.now + 3.hour
end
