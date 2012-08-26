class SaveTestsToFile < ActiveRecord::Migration
  def self.up
    ProblemTest.all.each do |test|
      test.save_to_file!
    end
  end

  def self.down
    FileUtils.rmtree "#{RAILS_ROOT}/#{ProblemTest::TESTS}"
  end
end
