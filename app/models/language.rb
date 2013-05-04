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
      @@ary
    end
  end
  attr_accessor :name, :description, :compiler, :interpreter
  attr_writer :memory, :time, :processes

  def initialize(options)
    options.each do |key, value|
      self.send("#{key}=", value)
    end
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
    name.downcase
  end

  def compiled?
    compiler.blank?
  end

  def interpreted?
    !compiled?
  end

  def invalid?
    compiler.blank? && interpreter.blank?
  end

  def compile(program)
    raise CompileError.new("Compiler or Interpreter needs") if invalid?

    return exe(program) if interpreted? # no need to compile

    cmd = (compiler % [program.fullname, program.path, program.basename])

    if system("#{cmd} 2> #{program.error}")
      return exe(program)
    else
      raise CompileError.new("Compile time error")
    end
  end

  def exe(program)
    if interpreted?
      interpreter + ' ' +  program.fullname
    else
      program.path
    end
  end

  class CompileError < Exception; end
end

