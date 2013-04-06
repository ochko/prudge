class Usage
  class State
    attr_reader :name, :abbr, :code, :pattern
    def initialize(name, abbr, code, pattern)
      @name, @abbr, @code, @pattern = name, abbr, code, pattern
    end

    TABLE = [
     ['unknown'         , 'ng'     , 0    , /^$/                           ],
     ['ok'              , 'ok'     , 2**0 , /^OK/                          ],
     ['time_exceeded'   , 'timeout', 2**1 , /^Time Limit Exceeded/         ],
     ['memory_exceeded' , 'memory' , 2**2 , /^Memory Limit Exceeded/       ],
     ['output_exceeded' , 'output' , 2**3 , /^Output Limit Exceeded/       ],
     ['invalid_function', 'invalid', 2**4 , /^Invalid Function/            ],
     ['non_zero_exit'   , 'return' , 2**5 , /^Command exited with non-zero/],
     ['terminated'      , 'ng'     , 2**6 , /^Command terminated by signal/],
     # new entry goes here. don't alter existing states above
     ['internal_error'  , 'ng'     , 2**16, /^Internal Error/              ]]

    TABLE.each do |row|
      cattr_accessor row.first
      send("#{row.first}=", new(*row))
    end

    def self.all
      @all ||= TABLE.map {|row| self.send row.first }
    end

    def self.detect(status)
      all.detect { |state| status =~ state.pattern } || unknown
    end

    def self.get(state)
      respond_to?(state) ? send(state) : unknown
    end
  end

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
    State.detect(status).code
  end

  private

  def strip(line, *patterns)
    return if line.blank?
    patterns.reduce(line) {|stripped, pattern| stripped.sub(pattern, '')}
  end
end
