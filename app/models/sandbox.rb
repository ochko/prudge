class Sandbox
  class << self
    def root
      Rails.root.join('judge','sandbox')
    end
    def safeexec
      root.join('safeexec')
    end
    def fsize
      2048 # 2Mbyte
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
      ext.blank? ? @solution.language.extension : ext
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
      break unless execute(exe, test)
      result = solution.results.create!(:test_id => test.id)
      break if result.failed?
    end
  end

  def compile
    FileUtils.rm(program.path) if File.exist?(program.path)
    FileUtils.ln(program.source, program.fullname, :force => true)

    return language.compile(program)
  ensure
    if File.exist?(program.error)
      solution.junk = IO.read(stderr).gsub(program.base, '')
      solution.save
    end
  end

  def execute(command, test)
    FileUtils.touch usage_path
    cmd = "#{self.class.safeexec} "+
      "--cpu #{problem.time + language.time_req} "+
      "--mem #{problem.memory + language.mem_req} "+
      "--fsize #{self.class.fsize} "+
      "--nproc #{language.nproc} "+
      "--usage #{program.usage} "+
      "--exec #{command} "+
      "0< #{test.input_path} " +
      "1> #{program.output} " +
      "2> #{program.error} "
    Rails.logger.info cmd
    system(cmd) # TODO: stdin, stdout, stderr = Open3.popen3('command')
  end

end
