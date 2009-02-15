module ResultsHelper
  def head_of(test_io, max=60)
    if test_io.nil?
      return ''
    end
    first_line = test_io.split(/\n/)[0]
    if first_line.nil?
      return ''
    end
    if first_line.size > max
      return first_line[0,max] + '...'
    else
      return first_line
    end
  end

end
