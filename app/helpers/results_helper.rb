module ResultsHelper
  def inverted_table(results)
    matrix = []
    matrix << ['Тэст', '', 'Ажиллагаа', 'Хугацаа', 'Санах ой', 'Хариу']
    results.each_with_index do |result, index|
      matrix << [index+1, 
                 test_purpose(result), 
                 translate_message(result.status), 
                 sec2milisec(result.time), 
                 result.memory, 
                 link_to(show_correctness(result.matched), result)]
    end
    content = '<table id="results-table">'
    matrix.transpose.each do |row|
      content << '<tr><td>' << row.join('</td><td>') << '</td></tr>'
    end
    content << '</table>'
  end

  def differ(diff)
    diff.gsub(/^(\-|\+|@){2}.+\n/,'').
      gsub('\ No newline at end of file','').
      gsub(/^\+(.+)\n/, '<ins>&raquo;\1</ins>').
      gsub(/^\-(.+)\n/, '<del> \1&raquo;</del>')
  end
  
end
