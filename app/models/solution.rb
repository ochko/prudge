class Solution < ActiveRecord::Base
  SOLUTIONS_DIR = 'judge/solutions'
  SOLUTIONS_PATH = "#{RAILS_ROOT}/#{SOLUTIONS_DIR}"
  EXECUTOR = "#{RAILS_ROOT}/judge/safeexec"

  belongs_to :contest
  belongs_to :problem, :counter_cache => 'tried_count'
  belongs_to :user, :counter_cache => true
  belongs_to :language
  has_many :results, :order => 'hidden ASC, matched DESC', :dependent => :destroy
  has_many :tests, :through => :problem, :order => 'hidden, id'

  has_attached_file :source, 
    :url => "/judge/solutions/:user/:problem/:id.code",
    :path => ":rails_root/judge/solutions/:user/:problem/:id.code"

  validates_attachment_presence :source
  validates_attachment_size :source, :less_than => 64.kilobytes
  
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :order => 'created_at',
           :dependent => :destroy,
           :order => 'created_at DESC'

  named_scope :effective, :conditions => { :invalidated => false }
  named_scope :best, :conditions => { :isbest => true }
  named_scope :correct, :conditions => { :correct => true }
  named_scope :for_user, lambda { |user| { :conditions => ['user_id =?', user.id], :include => [:language, :problem], :order => 'created_at desc' } }
  named_scope :valuable, :conditions => 'percent > 0'

  def dir()         "#{self.user.solutions_dir}/#{self.problem_id}" end
  def exe_name()    self.source_file_name.split('.').first end
  def exe_path()    "#{user.exe_dir}/#{exe_name}" end
  def output_path() "#{user.exe_dir}/#{self.problem_id}.output" end
  def input_path()  "#{user.exe_dir}/#{self.problem_id}.input"  end
  def error_path()  "#{user.exe_dir}/#{self.problem_id}.error"  end
  def usage_path()  "#{user.exe_dir}/#{self.problem_id}.usage"  end
  def source_path() "#{File.dirname(source.path)}/#{source_file_name}" end

  def owned_by?(someone)
    self.user_id == someone.id
  end

  def invalidate!
    update_attributes(:invalidated => true)
  end

  def lock!
    self.update_attribute(:locked, true)
  end

  def locked?
    locked
  end

  def freezed?
    self.contest && self.contest.finished?
  end

  def apply_contest
    self.contest = nil
    if self.problem.contest && !self.problem.contest.finished?
      self.contest = self.problem.contest
    end
  end

  def check!
    cleanup!
    if compile
      self.tests.each do |test|
        break unless execute(test)
        result = results.create!(:test_id => test.id)
        break if result.failed?
      end
      summarize_results!
      nominate_for_best!
    end
  end

  def compile
    FileUtils.mkdir(user.exe_dir) unless File.directory? user.exe_dir
    FileUtils.rm(exe_path) if File.exist? exe_path
    FileUtils.ln(source.path, source_path, :force => true)
    compiled = system("#{language.compiler % [source_path, exe_path, exe_name]} 2> #{error_path}")
    save_error_output! unless compiled
    update_attribute(:nocompile, !compiled)
    compiled
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

  def save_error_output!
    if File.exist?(error_path)
      self.junk = IO.readlines(error_path).join('<br/>').
        gsub(SOLUTIONS_PATH,'').gsub(/[0-9]+\//,'')
      FileUtils.rm(error_path)
    else
      self.junk = ''
    end
    self.save!
  end

  def cleanup!
    self.results.clear
    self.user.decrement!(:points, self.point) if self.point > 0
    self.problem.decrement!(:solved_count) if self.correct
    self.update_attributes(:checked => false,
                             :nocompile => false,
                             :invalidated => false,
                             :correct => false,
                             :percent => 0.0,
                             :time => 5000.0,
                             :isbest => false,
                             :point => 0.0,
                             :junk => nil) 
    
  end

  def summarize_results!
    unless self.results.empty?
      passed = self.results.correct.real.size
      total = self.problem.tests.real.size
      self.update_attributes(:checked => true,
                             :correct => (passed == total),
                             :percent => (passed.to_f / total),
                             :time => (self.results.sum(:time) / self.results.size),
                             :point => (passed.to_f / total) * self.problem.level) 
      self.user.increment!(:points, self.point) if self.point > 0
      self.problem.increment!(:solved_count) if self.correct
    end
  end
  
  after_destroy { |solution| solution.user.decrement!(:points, solution.point)}
  
  def nominate_for_best!
    siblings = Solution.
      find(:all, :conditions => ['user_id = ? and problem_id = ?',
                                 user_id, problem_id],
           :order => "percent DESC, time ASC")
    siblings.each { |sibling| sibling.update_attribute(:isbest, false)}
    siblings.first.update_attribute(:isbest, true)
  end

  def touch!
    self.update_attribute(:touched, true)
  end

end
