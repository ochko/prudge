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

  def inverted_table(results)
    matrix = []
    matrix << ['Тэст', '', 'Ажиллагаа', 'Хугацаа', 'Санах ой', 'Хариу']
    results.each_with_index do |result, index|
      matrix << [index+1, 
                 test_purpose(result), 
                 translate_message(result.status), 
                 sec2milisec(result.time), 
                 result.memory, 
                 show_correctness(result.matched)]
    end
    content = '<table id="results-table">'
    matrix.transpose.each do |row|
      content << '<tr><td>' << row.join('</td><td>') << '</td></tr>'
    end
    content << '</table>'
  end
end
