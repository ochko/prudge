class Sandbox
  def initialize(solution)
    self.solution = solution
  end

  attr_accessor :solution

  class << self
    def dir
      'sandbox'
    end
  end
end
