Gem::Specification.new do |s|
  s.name = 'ssl_requirement'
  s.version = '1.0.200807043'
  s.date = '2008-07-04'

  s.summary = "Allow controller actions to force SSL on specific parts of the site."
  s.description = "SSL requirement adds a declarative way of specifying that certain actions should only be allowed to run under SSL, and if they're accessed without it, they should be redirected."

  s.authors = ['RailsJedi', 'David Heinemeier Hansson']
  s.email = 'railsjedi@gmail.com'
  s.homepage = 'http://github.com/jcnetdev/ssl_requirement'

  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'rails', ['>= 2.1']

  s.files = ["README",
             "init.rb",
             "lib/ssl_requirement.rb",
             "rails/init.rb",
             "ssl_requirement.gemspec"]

  s.test_files = ["test/ssl_requirement_test.rb"]

end
