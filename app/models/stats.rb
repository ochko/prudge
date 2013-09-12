class Stats
  class << self
    def compilations
      getset('compilations') do
        Solution.maximum :id
      end
    end

    def runs
      getset('runs') do
        Result.maximum :id
      end
    end

    def problems
      getset('problems') do
        Problem.count
      end
    end

    def points
      getset('points') do
        Integer(User.sum(:points))
      end
    end

    def refresh(key)
      Rails.cache.delete(key)
    end

    private

    def getset(key)
      Rails.cache.read(key) ||
        begin
          value = yield
          Rails.cache.write(key, value)
          value
        end
    end
  end
end
