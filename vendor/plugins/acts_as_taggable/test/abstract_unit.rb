$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'

require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'active_support/binding_of_caller'
require 'active_support/breakpoint'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'mysql'])

ActiveRecord::Base.connection.drop_table :topics rescue nil
ActiveRecord::Base.connection.drop_table :companies rescue nil
ActiveRecord::Base.connection.drop_table :posts rescue nil

ActiveRecord::Base.connection.create_table :topics do |t|
  t.column :title, :string
end

ActiveRecord::Base.connection.create_table :companies do |t|
  t.column :name, :string
end

ActiveRecord::Base.connection.create_table :posts do |t|
  t.column :title, :string
end

class Test::Unit::TestCase #:nodoc:
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
  self.use_instantiated_fixtures = false
  self.use_transactional_fixtures = (ENV['AR_NO_TX_FIXTURES'] != "yes")
    
  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures/", table_names, {}, &block)
  end
end
