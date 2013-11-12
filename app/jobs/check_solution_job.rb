class CheckSolutionJob < BaseJob
  @queue = :high

  def self.perform(id)
    return unless Solution.exists?(id) # solution updated while job is in queue

    solution = Solution.find(id)
    sandbox = Sandbox.new(solution)
    sandbox.run
  end
end
