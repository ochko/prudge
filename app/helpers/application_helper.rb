module ApplicationHelper
  def logged_in?
    current_user
  end

  def show_correctness(correct)
    if correct
      image_tag('ok.png')
    else
      image_tag('ng.png')
    end
  end    

  def show_percent(percent)
    content_tag(:span, content_tag(:span, "#{percent}%", :style =>"width:#{percent}%; overflow:visible;"), :class=>'percent')
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
      image_tag('run-ok.png', :title=>'Хэвийн ажиллав')
    elsif msg.strip.eql?('Time Limit Exceeded')
      image_tag('run-timeout.png', :title=>'Хугацаа хэтрэв')
    elsif msg.strip.eql?('Memory Limit Exceeded')
      image_tag('run-memory.png', :title=>'Санах ой хэтрэв')
    elsif msg.strip.eql?('Output Limit Exceeded')
      image_tag('run-output.png', :title=>'Гаралт хэтрэв')
    elsif msg.strip.eql?('Invalid Function')
      image_tag('run-invalid.png', :title=>'Буруу үйлдэл')
    elsif msg.strip[0,19].eql?('Command exited with')
      image_tag('run-return.png', :title=>'Алдаа буцаалаа')
    else
      image_tag('run-ng.png', :title=>'Үл мэдэгдэх алдаа')
    end
  end

  def test_purpose(result)
    if result.test.hidden
      image_tag('test-hidden.png', :title => 'Харагдахгүй тэст')
    else
      link_to(image_tag('test-open.png', :title => 'Тэстийг харах'), result)
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
        list += link_to(standing(s),c)
      end
    }
    return list
  end

  def prepare_wmd_if(needed)
    if needed
      js = stylesheet_link_tag('wmd')
      js << javascript_include_tag('showdown')
      js << javascript_tag('wmd_options = {"output":"Markdown"}')
      js << javascript_include_tag('wmd')      
      js << javascript_tag('$(function() { createWmd("textarea", "#preview"); }); ')
    end
  end
end
