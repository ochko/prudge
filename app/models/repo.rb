class Repo
  class << self
    def path
      'judge/solutions'
    end

    def root
      Rails.root.join(path)
    end

    attr_accessor :git
  end

  attr_accessor :dir, :user

  def initialize(user)
    raise "User#id is blank!" if user.id.blank?

    self.user = user
    self.dir = Repo.root.join(user.id.to_s)
  end

  def git
    self.class.git
  end

  def prepare
    init unless ready?
  end

  def ready?
    configuration('user.name') == user.login
  end

  def init
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    inside do
      if run('init', '--quiet', '.')
        configure('user.name', user.login)
        configure('user.email', user.email)
      end
    end
  end

  def commit(path, comment='updated')
    inside do
      prepare

      if new?(path) || changed?(path)
        run('add', '--', path) && run('commit', "-m #{comment}")
      end
    end
  end

  def new?(path)
    !tracked?(path)
  end

  def tracked?(path)
    run('ls-files', '--error-unmatch', '--', path)
  end

  def changed?(path)
    !run('diff', '--no-ext-diff', '--quiet', '--exit-code', '--', path)
  end

  def ignore(pattern)
    File.open(dir.join('.gitignore'), 'w+') do |gitignore|
      gitignore.puts(pattern)
    end
  end

  def configuration(key)
    inside do
      return %x(#{git} config --local --get #{key}).strip
    end
  end

  def configure(key, value)
    inside do
      run('config', '--local', key, value)
    end
  end

  private

  def run(*command)
    system(git, *command)
  end

  def inside
    if @inside # already inside
      yield
    else
      FileUtils.cd dir do |repo|
        begin
          @inside = repo
          yield
        ensure
          @inside = nil
        end
      end
    end
  end
end
