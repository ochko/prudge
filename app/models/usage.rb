class Usage
  def initialize(raw)
    @raw = raw
    parse
  end

  attr_accessor :status, :time, :memory, :state

  def parse
    lines = @raw.split("\n")
    self.status = lines[0]
    self.time = strip(lines[-1], 'cpu usage: ', ' miliseconds')
    self.memory = strip(lines[-2], 'memory usage: ', ' kbytes')
  end

  def state
    STATES.each do |key, val|
      return val if status =~ key
    end
    0 # default/unknown
  end

  private

  STATES = {
    # 0 is reserved for default/unknown state
    /^OK/                           => 2**0,
    /^Time Limit Exceeded/          => 2**1,
    /^Memory Limit Exceeded/        => 2**2,
    /^Output Limit Exceeded/        => 2**3,
    /^Invalid Function/             => 2**4,
    /^Command exited with non-zero/ => 2**5,
    /^Command terminated by signal/ => 2**6,
    # new states go here. don't alter existing
    /^Internal Error/               => 2**16
  }

  def strip(line, *patterns)
    return if line.blank?
    patterns.reduce(line) {|stripped, pattern| stripped.sub(pattern, '')}
  end
end
