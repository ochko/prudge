module LessonsHelper
  def tag_links(tags)
    links = ''
    for tag in tags.split(' ')
      links += link_to(tag, :action=>'search',
                       :field=>'tags', :query=>tag)
      links += ' '
    end
    return links
  end
end
