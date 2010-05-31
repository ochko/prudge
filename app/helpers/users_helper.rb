module UsersHelper
  def levels_legend(tag)
    legend = ''
    Contest::LEVEL_NAMES.each do |level, name|
      if level != 0
        from = Contest::LEVEL_POINTS[level-1]
        to = Contest::LEVEL_POINTS[level]
        from = '' if from == 0
        to = '' if to == 1000
        legend << content_tag(tag, "#{name}: #{from}~#{to}", :class =>"rank_#{level}")
      end
    end 
    legend
  end
end
