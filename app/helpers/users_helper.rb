module UsersHelper
  def levels_legend(tag)
    legend = ''
    [1, 2, 4, 8, 16, 32, 64, 128].each do |level|
      name = Contest::LEVEL_NAMES[level]
      legend << content_tag(tag, "~#{Contest::LEVEL_POINTS[level]}", :class =>"rank_#{level}")
    end 
    legend
  end

  def link_to_twitter(id)
    handle = id.delete('@')
    link_to "@#{handle}", "https://twitter.com/#{handle}"
  end
end
