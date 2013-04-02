class Language < ActiveRecord::Base
  has_many :solutions

  attribute_alias :runner, :interpreter

  def extension
    name.downcase
  end

  def compiled?
    compiler.blank?
  end

  def interpreted?
    !compiled?
  end

  def compile(program)
    return exe(program) if interpreted? # no need to compile

    cmd = (compiler % [program.fullname, program.path, program.basename])

    if system("#{cmd} 2> #{program.error}")
      return exe(program)
    else
      raise CompileError.new
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

