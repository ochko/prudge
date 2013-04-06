class Sandbox
  class << self
    def root
      Rails.root.join('judge','sandbox')
    end
  end

  attr_reader :solution, :user, :problem, :dir, :program, :language

  def initialize(solution)
    @solution = solution
    @user = solution.user
    @problem = solution.problem
    @language = solution.language
    @program = Program.new(self, solution)
    @dir = self.class.root.join(user.id.to_s)
    FileUtils.mkdir(dir) unless File.directory?(dir)
  end

  class Program
    def initialize(solution)
      @base = sandbox.dir
      @solution = solution
      @problem = solution.problem
      @source = solution.source
      @filename = @source.original_filename.strip
    end

    def basename
      base = File.basename(@filename)
      base.blank? ? @solution.id.to_s : base
    end

    def extname
      ext = File.extname(@filename)
      ext.blank? ? language.extension : ext
    end

    def fullname
      @base.join "#{basename}.#{extname}"
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
    solution.summarize!
  rescue Language::CompileError
    solution.errored!
  end

  def check(exe)
    @problem.tests.each do |test|
      break unless usage = execute(exe, test)
      result = solution.results.
        create!(:test_id => test.id,
                :usage   => usage)
      break if result.failed?
    end
  end

  def prepare
    FileUtils.rm(program.path) if File.exist?(program.path)
    FileUtils.ln(program.source, program.fullname, :force => true)
  end

  def clean
    if File.exist?(program.error)
      solution.junk = IO.read(stderr).gsub(program.base, '')
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
    runner = Runner.new(language, program, test, command)
    runner.exec
  end

  class Runner
    class << self
      def binary
        Sandbox.root.join('safeexec')
      end
      def fsize
        2048 # 2Mbyte
      end
    end

    def initialize(language, program, test, command)
      @language, @program, @test, @command = language, program, test, command
    end

    attr_reader :language, :program, :test, :command

    def exec
      FileUtils.touch program.usage
      # TODO: stdin, stdout, stderr = Open3.popen3('command')
      system("#{self.class.binary} #{options.join(' ')}")
      return Usage.new(IO.read(program.usage))
    ensure
      FileUtils.rm(program.usage) if File.exist?(program.usage)
    end

    def options
      ["--cpu #{time}",
       "--mem #{memory}",
       "--fsize #{self.class.fsize}",
       "--nproc #{language.nproc}",
       "--usage #{program.usage}",
       "--exec #{command}",
       "0< #{test.input_path}" ,
       "1> #{program.output}" ,
       "2> #{program.error}"]
    end

    def time
      problem.time + language.time_req
    end

    def memory
      problem.memory + language.mem_req
    end
  end
end
