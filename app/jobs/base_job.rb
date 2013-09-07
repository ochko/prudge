class BaseJob
  @queue = :low

  class << self
    def on_failure(exception, *args)
      Exceptional.handle exception, "#{name} #{args.join ', '}"
    end
  end
end
