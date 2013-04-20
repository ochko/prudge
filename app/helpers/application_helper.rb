# -*- coding: utf-8 -*-
module ApplicationHelper
  def title
    @title || t("title.#{controller_name}.#{action_name}")
  end

  def logged_in?
    current_user
  end

  def link_to_twitter(id)
    handle = id.delete('@')
    link_to "@#{handle}", "https://twitter.com/#{handle}"
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

  def markdown(text)
    raw BlueCloth.new(text).to_html
  end

  def school_names
    User.where("school is not null and school != ''").order(:school).pluck(:school).uniq
  end

  def error_messages_for(model)
    return unless model.errors.any?
    content_tag(:ul,
                model.errors.full_messages.reduce('') { |errors, msg|
                  errors << content_tag(:li, msg)
                })
  end
end
