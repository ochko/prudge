class CheckSolutionJob < BaseJob
  @queue = :high

  def self.perform(id)
    solution = Solution.find(id)
    sandbox = Sandbox.new(solution)
    sandbox.run
  end
end
