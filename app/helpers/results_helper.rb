# -*- coding: utf-8 -*-
module ResultsHelper
  def differ(diff)
    diff.gsub(/^(\-|\+|@){2}.+\n/,'').
      gsub('\ No newline at end of file','').
      gsub(/^\+(.+)\n/, '<ins>&raquo;\1</ins>').
      gsub(/^\-(.+)\n/, '<del> \1&raquo;</del>')
  end

  def results_table_horizontal(results)
    matrix_to_table(humanized_results_matrix(results).transpose, "results-table")
  end

  def results_table_vertical(results)
    matrix_to_table(humanized_results_matrix(results), "results-table")
  end

  private

  def humanized_results_matrix(results)
    header = ['Тэст', '', 'Ажиллагаа', 'Хугацаа', 'Санах ой', 'Хариу']
    index = 0
    results.reduce([header]) do |matrix, result|
      matrix << [index += 1,
                 render_viewable(result.hidden), 
                 translate_message(result.execution),
                 sec2milisec(result.time), 
                 result.memory, 
                 link_to(show_correctness(result.correct?), result)]
    end
  end

  def matrix_to_table(matrix, id)
    content = ["<table id='#{id}'>"]
    matrix.each do |row|
      content << "<tr><td>" << row.join('</td><td>') << '</td></tr>'
    end
    content << "</table>"
    content.join
  end
  
end
