class Twitit
  attr_accessor :message

  def initialize(message)
    self.message = message
  end

  def self.update(message)
    job = new(message)
    Delayed::Job.enqueue job
  end

  def twit
    Twitter.update(message)
  end

  alias :perform :twit

end
