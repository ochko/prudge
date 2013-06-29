class MigrateTestsToPaperclip < ActiveRecord::Migration
  def self.up
    values("select id from problem_tests").each do |test_id|
      record = one("select id, problem_id, input, output from problem_tests where id=#{test_id}")
      store(record)
    end
    remove_column :problem_tests, :input
    remove_column :problem_tests, :output
  end

  def self.down
    add_column :problem_tests, :text, "input",  :limit => 16777215
    add_column :problem_tests, :text, "output", :limit => 16777215

    ProblemTest.reset_column_information

    ProblemTest.all.each do |test|
      destore(test)
    end
  end

  def self.store(record)
    dir = Rails.root.join('judge', 'tests', record[:problem_id].to_s)
    FileUtils.mkpath dir

    input = dir.join("#{record[:id]}.in")
    output = dir.join("#{record[:id]}.out")

    File.open(input, 'w') { |file| file.write(record[:input].gsub(/\r/,'')) }
    File.open(output,'w') { |file| file.write(record[:output].gsub(/\r/,'')) }

    test = ProblemTest.find record[:id]
    test.input = File.open(input)
    test.output = File.open(output)
    test.save!
  end

  def self.destore(test)
    test[:input] = File.open(test.input.path, 'r'){ |f| f.read }
    test[:output] = File.open(test.output.path, 'r'){ |f| f.read }
    test.save!
  end

  private

  def self.values(sql)
    conn.select_values sql
  end

  def self.one(sql)
    conn.select_one(sql).symbolize_keys
  end

  def self.conn
    @conn ||= ActiveRecord::Base.connection
  end

end
