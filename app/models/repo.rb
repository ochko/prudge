class Repo
  attr_accessor :dir

  def initialize(dir)
    self.dir = Pathname.new(dir)
  end

  def init(name, email)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    FileUtils.cd dir do |repo|
      if run('init', '--quiet', '.')
        run('config', 'user.name', name)
        run('config', 'user.email', email)
      end
    end
  end

  def commit(path, comment='updated')
    FileUtils.cd dir do |repo|
      run('add', path) && run('commit', "-m #{comment}")
    end
  end

  def ignore(pattern)
    File.open(dir.join('.gitignore'), 'w+') do |gitignore|
      gitignore.puts(pattern)
    end
  end

  private

  def run(*command)
    system(self.class.bin, *command)
  end

  class << self
    # aka SOLUTIONS_DIR
    def path
      'judge/solutions'
    end
    # aka SOLUTIONS_PATH
    def root
      Rails.root.join path
    end
    def bin
      return @bin if defined? @bin
      unless (path = `which git`.strip).blank?
        @bin = path
      else
        @bin = %w[/usr/bin/git /usr/local/bin/git /opt/local/bin/git].detect do |path|
          File.executable?(path)
        end
      end
    end
    
  end
end
