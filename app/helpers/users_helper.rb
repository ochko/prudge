module UsersHelper
  SOCIAL_MEDIA_URLS = { 
    'twitter' => 'http://www.twitter.com/%s',
    'facebook' => 'http://www.facebook.com/%s',
    'blogger' => 'http://%s.blogspot.com',
    'google' => 'http://www.google.com/profiles/%s',
    'hi5' => 'http://%s.hi5.com',
    'yahoo' => 'http://profiles.yahoo.com/%s'
  }

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

  def social_media_link(user, media)
    id = user.send("social_#{media}")
    if id && !id.empty?
      link_to(image_tag("icon-#{media}.png"), 
              SOCIAL_MEDIA_URLS[media] % user.send("social_#{media}"),
              :title => media.capitalize,
              :target => media)
    end
  end
end
