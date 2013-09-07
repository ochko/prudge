class Sandbox
  class << self
    def root
      Rails.root.join(Settings.judge, 'sandbox')
    end
  end

  attr_reader :solution, :user, :problem, :dir, :program, :language, :problem

  def initialize(solution)
    @solution = solution
    @user = solution.user
    @problem = solution.problem
    @language = solution.language
    @dir = self.class.root.join(user.id.to_s)
    @program = Program.new(self, solution)
    FileUtils.mkdir(dir) unless File.directory?(dir)
  end

  class Program
    def initialize(sandbox, solution)
      @base = sandbox.dir
      @solution = solution
      @problem = solution.problem
      @source = solution.source
      @filename = @source.original_filename.strip
    end

    def basename
      base = File.basename(@filename)
      base.blank? ? @solution.id.to_s : base.sub(/#{extname}$/,'')
    end

    def extname
      ext = File.extname(@filename)
      ext.blank? ? language.extension : ext
    end

    def fullname
      @base.join "#{basename}#{extname}"
    end

    def path
      @base.join basename
    end

    def source
      @source.path
    end

    def output
      @base.join "#{@problem.id}.output"
    end
    def error
      @base.join "#{@problem.id}.error"
    end
    def usage
      @base.join "#{@problem.id}.usage"
    end
  end

  def run
    exe = compile
    check(exe)
    solution.attempted!
    solution.summarize!
  rescue Language::CompileError
    solution.defunct!
  end

  def check(exe)
    solution.reset! unless solution.results.empty?

    @problem.tests.each do |test|
      break unless usage = execute(exe, test)
      result = judge(test, usage)
      break if result.failed?
    end
  end

  def judge(test, usage)
    output = Output.new(program.output, test)
    solution.results.
      create!(:test   => test,
              :usage  => usage,
              :result => output,
              :hidden => test.hidden)
  end

  def prepare
    FileUtils.rm(program.path) if File.exist?(program.path)
    FileUtils.ln(program.source, program.fullname, :force => true)
  end

  def clean
    if File.exist?(program.error)
      solution.junk = IO.read(program.error).gsub("#{dir}", '')
      solution.save
    end
  end

  def compile
    prepare
    return language.compile(program)
  ensure
    clean
  end

  def execute(command, test)
    runner = Runner.new(language, program, test, command, problem)
    runner.exec
  end

  class Output
    cattr_accessor :diff

    attr_reader :path, :diff

    def initialize(path, test)
      @path = path
      @diff = "#{@path}.diff"
      @test = test

      system("#{self.class.diff} #{@path} #{@test.output.path} > #{@diff}")
    end

    def matched?
      @matched ||= File.read(@diff).blank?
    end
  end

  class Runner
    cattr_accessor :binary

    def self.fsize
      2048 # 2Mbyte
    end

    def initialize(language, program, test, command, problem)
      @language, @program, @test, @command, @problem = language, program, test, command, problem
    end

    attr_reader :language, :program, :test, :command, :problem

    def exec
      FileUtils.touch program.usage
      system("#{self.class.binary} #{options.join(' ')}")
      return Usage.new(IO.read(program.usage))
    ensure
      FileUtils.rm(program.usage) if File.exist?(program.usage)
    end

    def options
      ["--cpu #{time}",
       "--mem #{memory}",
       "--fsize #{self.class.fsize}",
       "--nproc #{language.processes}",
       "--usage #{program.usage}",
       "--exec #{command}",
       "0< #{test.input.path}" ,
       "1> #{program.output}" ,
       "2> #{program.error}"]
    end

    def time
      problem.time + language.time
    end

    def memory
      problem.memory + language.memory
    end
  end
end
