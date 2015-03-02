# Programming language responsible for compiling a source code
#
# @name String
# @describtion String
# @compiler String for compiler command contains at least 2 `%s` expression.
#   first %s is for source file path
#   second %s is for executable path
#   third %s is optional, like class name containin main method etc
#   Examples::
#     C:    `/usr/bin/gcc -x c -lm %s -o %s`
#     Java: `/usr/bin/gcj %s -o %s --main=%s -lm`
#     C#:   `gmcs -out:Program.exe -target:exe %s && mkbundle Program.exe --deps --static -o Program.c -oo Program.o -c && cc -ggdb -o %s -Wall Program.c -I/usr/local/include/mono-2.0 -L/usr/local/lib -lmono-2.0 -liconv -lm Program.o`
# @interpreter String for scrtiping language interpreter
#   It doesn't need any parameter.
#   Examples::
#     Ruby: `/usr/local/bin/ruby`
#     Python: `/opt/python/bin/python3`
#
class Language
  class << self
    @@ary = []
    @@hash = {}

    def init
      YAML.load_file(Rails.root.join('config', 'languages.yml')).each do |options|
        add options
      end
    end

    def add(options)
      language = new(options)
      @@ary << language
      @@hash[language.name.downcase] = language
    end

    def [](name)
      init if @@hash.empty?
      @@hash[name.to_s.downcase]
    end

    def all
      init if @@hash.empty?
      @@ary.select(&:active)
    end
  end

  attr_accessor :name, :description, :compiler, :interpreter
  attr_writer :memory, :time, :processes, :extension, :active

  def initialize(options)
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def active
    @active.nil? ? true : @active
  end

  def memory
    @memory || 0
  end

  def time
    @time || 0
  end

  def processes
    @processes || 0
  end

  def extension
    @extension || ('.' + name.downcase)
  end

  def compiled?
    !compiler.blank?
  end

  def interpreted?
    !compiled?
  end

  def invalid?
    compiler.blank? && interpreter.blank?
  end

  # Compiles if language is compiled
  #
  # == Parameters:
  # progam::
  #   object that responds to `fullname`, `path` and `basename`
  #
  # == Returns:
  # Compiled executable path
  #
  def compile(program)
    raise CompileError.new("Compiler or Interpreter needs") if invalid?
    raise CompileError.new("Language is not supported") unless active

    return exe(program) if interpreted? # no need to compile

    if Kernel.system command(program)
      return exe(program)
    else
      raise CompileError.new("Compile time error")
    end
  end

  def command(program)
    cmd = compiler % { source: program.fullname,
                       output: program.path,
                       basename: program.basename }
    "#{cmd} 2> #{program.error}"
  end

  def exe(program)
    if interpreted?
      "#{interpreter} #{program.fullname}"
    else
      program.path
    end
  end

  class CompileError < Exception; end
end
