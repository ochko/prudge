module TopicsHelper

  def topic_title_for(param_type)
    if !param_type
      'Хэлэлцүүлгүүд'
    elsif param_type.eql?('contest')
      'Тэмцээний хэлэлцүүлгүүд'
    elsif param_type.eql?('problem')
      'Бодлогын хэлэлцүүлгүүд'
    elsif param_type.eql?('lesson')
      'Хичээлийн хэлэлцүүлгүүд'
    else
      'Хэлэлцүүлгүүд'
    end
  end

end
