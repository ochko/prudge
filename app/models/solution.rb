class Solution < ActiveRecord::Base
  SOLUTIONS_DIR = 'judge/solutions'
  SOLUTIONS_PATH = "#{RAILS_ROOT}/#{SOLUTIONS_DIR}"
  EXECUTOR = "#{RAILS_ROOT}/judge/safeexec"

  belongs_to :contest
  belongs_to :problem
  belongs_to :user
  belongs_to :language
  has_many :results, :dependent => :destroy
  has_many :tests, :through => :problem, :order => 'hidden, id'

  has_attached_file :source, 
  :url => "/judge/solutions/:user/:problem/:id.code",
  :path => ":rails_root/judge/solutions/:user/:problem/:id.code"

  # TODO: Delete after migration
  #has_attachment :path_prefix => 'judge/src'

  validates_attachment_presence :source
  validates_attachment_size :source, :less_than => 64.kilobytes

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :order => 'created_at',
           :dependent => :destroy

  named_scope :effective, :conditions => { :invalidated => false }
  named_scope :best, :conditions => { :isbest => true }

  after_save { |s| s.user.collect_caches! }
  after_destroy { |s| s.user.collect_caches! }

  def dir()         "#{self.user.solutions_dir}/#{self.problem_id}" end
  def exe_name()    self.source_file_name.split('.').first end
  def exe_path()    "#{user.exe_dir}/#{exe_name}" end
  def output_path() "#{user.exe_dir}/#{self.problem_id}.output" end
  def input_path()  "#{user.exe_dir}/#{self.problem_id}.input"  end
  def error_path()  "#{user.exe_dir}/#{self.problem_id}.error"  end
  def usage_path()  "#{user.exe_dir}/#{self.problem_id}.usage"  end

  def invalidate!
    update_attributes(:invalidated => true)
  end

  def check!
    return unless compile
    cleanup!
    self.tests.each do |test|
      break unless execute(test)
      result = results.create!(:test_id => test.id)
      break if result.failed?
    end
    summarize_results!
    nominate_for_best!
  end

  def compile
    FileUtils.mkdir(user.exe_dir) unless File.directory? user.exe_dir
    FileUtils.rm(exe_path) if File.exist? exe_path
    system("#{language.compiler % [source.path, exe_path, exe_name]} 2> #{error_path}")
  end

  def execute(test)
    FileUtils.touch usage_path
    cmd = "#{EXECUTOR} "+
           "--cpu #{problem.time + language.time_req} "+
           "--mem #{problem.memory + language.mem_req} "+
           "--usage #{usage_path} "+
           "--exec #{exe_path} "+
           "0< #{test.input_path} " +
           "1> #{output_path} " +
           "2> #{error_path} "
    system(cmd)
  end

  def cleanup!
    self.results.clear
    update_attributes(:checked => false,
                      :invalidated => false,
                      :correct => false,
                      :percent => 0.0,
                      :time => 5000.0,
                      :isbest => false,
                      :point => 0.0) unless self.locked
  end

  def summarize_results!
    self.update_attributes(:checked => true,
                           :correct => (self.results.correct.real.size == 
                                        self.problem.tests.real.size),
                           :percent => (self.results.correct.real.size / 
                                        self.problem.tests.real.size),
                           :time => (self.results.correct.sum('time') / 
                                     self.results.correct.size),
                           :point => (self.results.correct.real.size / 
                                      self.problem.tests.real.size) * 
                           self.problem.level)
  end

  def nominate_for_best!
    siblings = Solution.
      find(:all, :conditions => ['user_id = ? and problem_id = ?',
                                 user_id, problem_id],
           :order => "percent DESC, time ASC")
    siblings.each { |sibling| sibling.update_attribute(:isbest, false)}
    siblings.first.update_attribute(:isbest, true)
  end


end
