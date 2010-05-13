module UsersHelper
  def levels_legend(tag)
    legend = ''
    Contest::LEVEL_NAMES.each do |level, name|
      if level != 0
        legend << content_tag(tag, "#{name}: #{Contest::LEVEL_POINTS[level-1]}-#{Contest::LEVEL_POINTS[level]}", :class =>"rank_#{level}")
      end
    end 
    legend
  end
end
