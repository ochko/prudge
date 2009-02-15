module ProblemTestsHelper
  MAX_LINE = 40
  def head_of(test_io)
    first_line = test_io.split('\n')[0]
    if first_line.size > MAX_LINE
      return first_line[0,MAX_LINE] + '...'
    else
      return first_line
    end
  end
end
