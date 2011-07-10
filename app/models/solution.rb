# -*- coding: utf-8 -*-
class Solution < ActiveRecord::Base
  SOLUTIONS_DIR = 'judge/solutions'
  SANDBOX_DIR = "#{RAILS_ROOT}/judge/sandbox"
  SOLUTIONS_PATH = "#{RAILS_ROOT}/#{SOLUTIONS_DIR}"
  EXECUTOR = "#{RAILS_ROOT}/judge/safeexec"
  MAX_OUTPUT = 2048 # 2Mbyte
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

  named_scope :best, :conditions => { :isbest => true }
  named_scope :correct, :conditions => { :correct => true }
  named_scope :for_user, lambda { |user| { :conditions => ['user_id =?', user.id], :include => [:language, :problem], :order => 'created_at desc' } }
  named_scope :valuable, :conditions => 'percent > 0'
  named_scope :by_speed, :order => 'time ASC, uploaded_at ASC'
  named_scope :for_contest, lambda { |c| { :conditions => ['contest_id =?', c.id] } }

  after_destroy { |solution| solution.user.decrement!(:points, solution.point)}

  after_create { |solution| solution.user.solution_uploaded! }

  def name() problem.name end
  def text() "Хэрэглэгч #{user.login} -ий бодолтод санал/зөвлөгөө/тусламж бичих" end

  def exe_name
    return @exe if @exe
    @exe = self.source_file_name.split('.').first
    @exe = self.id if @exe.empty?
    @exe
  end

  def dir()         "#{self.user.solutions_dir}/#{self.problem_id}" end
  def exe_path()    "#{user.exe_dir}/#{exe_name}" end
  def script_path() "#{SANDBOX_DIR}/#{source_file_name}" end
  def output_path() "#{user.exe_dir}/#{self.problem_id}.output" end
  def input_path()  "#{user.exe_dir}/#{self.problem_id}.input"  end
  def error_path()  "#{user.exe_dir}/#{self.problem_id}.error"  end
  def usage_path()  "#{user.exe_dir}/#{self.problem_id}.usage"  end
  def source_path() "#{File.dirname(source.path)}/#{source_file_name}" end  

  def owned_by?(someone)
    self.user_id == someone.id
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
    return true if language.compiler.blank?

    FileUtils.mkdir(user.exe_dir) unless File.directory? user.exe_dir
    FileUtils.rm(exe_path) if File.exist? exe_path
    FileUtils.ln(source.path, source_path, :force => true)
    compiled = system("#{language.compiler % [source_path, exe_path, exe_name]} 2> #{error_path}")
    fetch_errors
    self.nocompile = !compiled
    save!
    compiled
  end

  def execute(test)
    if language.runner.blank?
      execute_compiled test
    else
      execute_interpreted test
    end
  end

  def execute_interpreted(test)
    begin
      FileUtils.ln(source.path, script_path, :force => true)
      safe_execute(test, language.runner + ' ' +  script_path)
    ensure
      FileUtils.rm(script_path) if File.exist? script_path
    end
  end

  def execute_compiled(test)
    safe_execute(test, exe_path)
  end

  def safe_execute(test, command)
    FileUtils.touch usage_path
    cmd = "#{EXECUTOR} "+
      "--cpu #{problem.time + language.time_req} "+
      "--mem #{problem.memory + language.mem_req} "+
      "--fsize #{MAX_OUTPUT} "+
      "--nproc #{language.nproc} "+
      "--usage #{usage_path} "+
      "--exec #{command} "+
      "0< #{test.input_path} " +
      "1> #{output_path} " +
      "2> #{error_path} "
    Rails.logger.info cmd
    system(cmd)    
  end

  def fetch_errors
    if File.exist?(error_path)
      self.junk = IO.readlines(error_path).join('<br/>').
        gsub(SOLUTIONS_PATH,'').gsub(/[0-9]+\//,'')
      FileUtils.rm(error_path)
    else
      self.junk = nil
    end
  end

  def code
    File.open(self.source.path, 'r'){ |f| f.read }
  end

  def cleanup!
    results.clear
    user.decrement!(:points, point) if point > 0 && isbest
    problem.decrement!(:solved_count) if correct
    update_attributes(:checked => false,
                      :nocompile => false,
                      :correct => false,
                      :percent => 0.0,
                      :time => 0.0,
                      :isbest => false,
                      :point => 0.0,
                      :junk => nil)     
  end

  def summarize_results!
    unless self.results.empty?
      passed = self.results.correct.real.size
      total = self.problem.tests.real.size
      self.checked = true
      self.correct = passed == total
      self.percent = passed.to_f / total
      self.time    = self.results.sum(:time) / self.results.size
      self.point   = (passed.to_f / total) * self.problem.level 
      self.solved_in ||= (self.correct && self.contest && self.contest.start < Time.now && (Time.now - self.contest.start))
      self.save!

      self.problem.increment!(:solved_count) if self.correct
    end
  end
  
  def nominate_for_best!
    former = Solution.
      last(:conditions => ['user_id = ? and problem_id = ? and id <> ?',
                           user_id, problem_id, id])
    if former
      if former.point < point
        user.increment!(:points, point - former.point)
        former.update_attribute(:isbest, false)
        update_attribute(:isbest, true)
      else
        former.update_attribute(:isbest, true)
        update_attribute(:isbest, false)
      end
    else
      user.increment!(:points, point)
      self.update_attribute(:isbest, true)
    end
  end

  def insert_to_repo
    FileUtils.cd self.user.solutions_dir do |repo| 
      system("/usr/bin/git add #{self.problem_id}")
      system("/usr/bin/git commit -m 'initial commit' #{self.problem_id}")
    end
  end

  def commit_to_repo
    FileUtils.cd self.user.solutions_dir do |repo| 
      system("/usr/bin/git commit -m 'updating' #{self.problem_id}")
    end
  end
  
end
