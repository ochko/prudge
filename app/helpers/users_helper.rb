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
    [1, 2, 4, 8, 16, 32, 64, 128].each do |level|
      name = Contest::LEVEL_NAMES[level]
      legend << content_tag(tag, "~#{Contest::LEVEL_POINTS[level]}", :class =>"rank_#{level}")
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
