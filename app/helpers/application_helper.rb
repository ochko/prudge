# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def merged_name(first, last)
    if !last.nil?
      return first + '.' + last[0,2]
    else
      return first
    end
  end

  def show_photo(photo)
    if !photo.nil?
      return image_tag(photo.public_filename(:thumb))
    else
      return image_tag('no-thumb-photo.png')
    end
  end

  def show_tiny_photo(photo)
    if !photo.nil?
      return image_tag(photo.public_filename(:tiny))
    else
      return image_tag('no-tiny-photo.png')
    end
  end

  def show_correctness(correct)
    if correct
      image_tag('ok.png')
    else
      image_tag('ng.png')
    end
  end

  def ok_or_ng(correct)
    (correct) ? 'ok' : 'ng'
  end

  def show_percent_word(all, some)
    if all == some
      return 'Бүгд зөв<br />' + image_tag('percent-all.png')
    elsif (all - some) < some
      return 'Ихэнх нь зөв<br />' + image_tag('percent-almost.png')
    elsif (all - some) == some
      return 'Хагас нь зөв<br />' + image_tag('percent-half.png')
    elsif some != 0
      return 'Ихэнх нь буруу<br />' + image_tag('percent-some.png')
    else
      return 'Бүгд буруу<br />' + image_tag('percent-none.png')
    end
  end

  def contest_type_link(type)
    link_to(type.name,
            :controller=> 'contest_types',
            :action=>'show',
            :id=>type.id)
  end

  def prize_link(prize)
    link_to(prize.name,
            :controller=>'prizes',
            :action=>'show',
            :id=>prize.id)
  end

  def sponsor_link(sponsor)
    link_to(sponsor.name,
            :controller=>'sponsors',
            :action=>'show',
            :id=>sponsor.id)
  end

  def contest_link(contest)
    link_to(contest.name,
            :controller=>'contests',
            :action=>'show',
            :id=>contest.id)
  end

  def problem_link(problem)
    link_to(problem.name,
            :controller=>'problems',
            :action=>'show',
            :id=>problem.id)
  end

  def language_link(l)
    link_to(l.name,
            :controller=>'languages',
            :action=>'show',
            :id=>l.id)
  end

  def fitted_textarea(text, rowmax=8, colmax=82, rowmin=2, colmin=36, cl='test')
    if text.nil?
      return ''
    end
    lines = text.split(/\n/)
    rows = lines.size
    for l in lines
      rows += l.chars.size/colmax;
    end
    if rows < rowmin
      rows = rowmin
    end
    if rows > rowmax
      rows = rowmax
    end
    cols = colmin
    for l in lines
      if l.length > cols
        cols = l.length
      end
    end
    if cols > colmax
      cols = colmax
    end
    "<textarea class='#{cl}' readonly cols='#{cols}' rows='#{rows}'>#{text}</textarea>"
  end

  def page_tag_link(tags)
    if tags.nil?
      return ''
    end

    links = ''
    for tag in tags.split(' ')
      links += link_to(tag, { :controller=> 'pages',
                       :action=>'search',
                         :field=>'tags', :query=>tag}, :class=>'tag')
      links += ' '
    end
    return links
  end

  def lesson_tag_link(tags)
    if tags.nil?
      return ''
    end

    links = ''
    for tag in tags.split(' ')
      links += link_to(tag, { :controller=> 'lessons',
                       :action=>'search',
                       :field=>'tags', :query=>tag}, :class=>'tag')
      links += ' '
    end
    return links
  end

  def task_tag_link(tags)
    if tags.nil?
      return ''
    end

    links = ''
    for tag in tags.split(' ')
      links += link_to(tag, { :controller=> 'tasks',
                       :action=>'search',
                       :field=>'tags', :query=>tag}, :class=>'tag')
      links += ' '
    end
    return links
  end

  def shorten(str, len)
    if str.length > len
      return str[0,len] + '...'
    end
    return str
  end

  def bytize(bytes)
    if bytes < 1024
      return bytes.to_s + 'b'
    elsif bytes < 1024*1024
      return (bytes/1024).to_s + 'Kb'
    else
      return (bytes/(1024*1024)).to_s + 'Mb'
    end
  end

  def test_type(test)
    if test.hidden
      "Жинхэнэ"
    else
      "Туршилт"
    end
  end

  def true_false(bool)
    if bool
      'Тийм'
    else
      'Үгүй'
    end
  end

  def sec2milisec(sec)
      "%0.3f" % (sec.to_f/1000)
  end

  def translate_message(msg)
    if msg.strip.eql?('OK')
      'Хэвийн'
    elsif msg.strip.eql?('Time Limit Exceeded')
      'Хугацаа хэтрэв'
    elsif msg.strip.eql?('Memory Limit Exceeded')
      'Санах ой хэтрэв'
    elsif msg.strip.eql?('Output Limit Exceeded')
      'Гаралт хэтрэв'
    elsif msg.strip.eql?('Invalid Function')
      'Буруу үйлдэл'
    elsif msg.strip[0,19].eql?('Command exited with')
      "Алдаа буцаалаа"
    else
      msg
    end
  end

  def test_purpose(result)
    if result.test.hidden
      image_tag('test-hidden.png')
    else
      link_to(image_tag('test-open.png'),
              :controller=>'results', :action=>'show',
              :id => result)
    end
  end

  def user_info_small(id)
    user = User.find(id)
    photo = user.photo
    if !photo.nil?
      return (link_to(image_tag(photo.public_filename(:tiny), :alt=>'photo') +
                      '<div class=small>%s</div>' % user.login,
                      :controller=>'account',
                      :action=>'show', :id=>id))
    else
      return (link_to(image_tag('no-tiny-photo.png', :alt=>'no photo') +
                      '<div class=small>%s</div>' % user.login,
                      :controller=>'account',
                      :action=>'show', :id=>id))
    end

  end

  def  standing(num)
    if num > 3
      return num
    end
    if num == 1
      image_tag('cup-gold.png', :title=> 'Алт')
    elsif num == 2
      image_tag('cup-silver.png', :title=> 'Мөнгө')
    elsif num == 3
      image_tag('cup-bronze.png', :title=> 'Хүрэл')
    end
  end

  def medal_list(standings)
    list =''
    medal_color = 1
    standings.sort{|a,b| a[1]<=>b[1]}.each { |c, s|
      if s < 4
        if medal_color != s
          medal_color = s
          list += '<br />'
        end
        list += link_to(standing(s),
                        :controller => 'contests',
                        :action=> 'show', :id=>c)
      end
    }
    return list
  end

  def show_banner
    banners = Banner.find(:all, :conditions => "parent_id is null and enabled is true",
                          :order=> "erembe")
    list =''
    for b in banners
      list += "<p>%s</p>" % link_to(image_tag(b.public_filename),
                      :controller=>'banners',
                      :action=>'click', :id=>b)
    end
    return list
  end

  def show_poll
    @poll = Poll.find(:first, :conditions=>'active = true')
    if !@poll.nil?
      @total = PollChoice.sum(:counter, :conditions=>["poll_id = ?", @poll.id])
      if @poll.nil?
        return
      else
        if session['polled']
          if @total > 0
            render :partial => 'polls/result'
          else
            render :partial => 'polls/poll'
          end
        else
          render :partial => 'polls/poll'
        end
      end
    end
  end

  def show_last
    @solutions = Solution.
      find(:all,
           :include => [:user, :problem],
           :limit => 10,
           :order => 'solutions.updated_at desc')

    render :partial => 'solutions/last'
  end

  def rank_name(points, total)
    if points.to_i > total*0.6
      return 'advanced'
    elsif points.to_i > total*0.3
      return 'intermediate'
    elsif points.to_i > total*0.05
      return 'beginner'
    else
      return 'challenger'
    end
  end

  def hugatsaa_zawsar(from_time, to_time = Time.now, include_seconds = true)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes == 0) ? '1 миунтаас бага' : '1 минут' unless include_seconds
      case distance_in_seconds
      when 0..4   then '5 секунд'
      when 5..9   then '10 секунд'
      when 10..19 then '20 секунд'
      when 20..39 then 'хагас минут'
      when 40..59 then '1 минут'
      else             '1 минут'
      end

    when 2..44           then "#{distance_in_minutes} минут"
    when 45..89          then '1 цаг'
    when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} цаг"
    when 1440..2879      then '1 өдөр'
    when 2880..43199     then "#{(distance_in_minutes / 1440).round} өдөр"
    when 43200..86399    then '1 сар'
    when 86400..525959   then "#{(distance_in_minutes / 43200).round} сар"
    when 525960..1051919 then '1 жил'
    else                      "#{(distance_in_minutes / 525960).round} жил"
    end
  end

  def who_is_online
    @whos_online = Array.new()
    onlines = CGI::Session::ActiveRecordStore::Session.
      find( :all,
            :conditions => [ 'updated_at > ?',
                             Time.now() - 20.minutes ])
    onlines.each do |online|
      id = online.data[:user]
      @whos_online << id if id
    end

    if @whos_online.size > 0
    @onlines = User.find(:all,
                         :conditions => "id IN (#{@whos_online.join(',')})"
                         )
    render :partial => 'account/online'
    else
      render :text => 'No online users'
    end
  end

end
