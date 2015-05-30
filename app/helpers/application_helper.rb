# -*- coding: utf-8 -*-
module ApplicationHelper
  def title
    @title ||= t(:title, :subject => subject,
                 :scope => [controller_name, action_name], :default => controller_name)
  end

  def tt(title)
    t(title, :scope => :title)
  end

  def subject
    return unless %w(edit show view index).include?(action_name)
    return unless instance = controller.instance_variable_get("@#{controller_name.singularize}")
    return unless instance.respond_to?(:name)
    instance.name
  end

  def flashy
    message, css = nil, nil

    if msg = flash[:notice] || params[:notice]
      message, css = msg, 'alert-success'
    elsif msg = flash[:error] || params[:error]
      message, css = msg, 'alert alert-error'
    elsif msg = flash[:warning] || params[:warning]
      message, css = msg, 'alert alert-info'
    elsif msg = flash[:alert] || params[:alert]
      message, css = msg, 'alert alert-error'
    end

    message_box_with_close_button(message, css)
  end

  def message_box_with_close_button(message, css='alert-success')
    return if message.blank?

    content_tag(:div,
                content_tag(:button,
                            content_tag(:i,'', :class => "icon-remove-circle"),
                            :type => 'button', :class => 'close',
                            'data-dismiss'=> 'alert') +
                message.html_safe,
                :class => "alert #{css} alert-block")
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
    (sec/1000.0).round(3)
  end

  def subsequent_dates(date1, date2, separator='~')
    date1.strftime("%Y-%m-%d %H:%M") + separator + date2.strftime("%H:%M")
  end

  def markdown(text)
    raw MarkdownRenderer.render(text)
  end

  def squeeze(text, size)
    chars = text.mb_chars
    length = chars.length

    return text if length <= size

    left = size - 2
    right = length - size + 1

    (chars[0...left] + '...' + chars[right...-1]).to_s
  end

  def school_names
    User.where("school is not null and school != ''").order(:school).pluck(:school).uniq
  end

  # TODO: rails 4 already has error_messages_for helper
  def error_messages_for(model)
    return unless model.errors.any?
    messages = model.errors.full_messages.map {|msg| content_tag(:li, ERB::Util.html_escape(msg)) }
    content = ''
    content << content_tag(:button, '&times;'.html_safe, :type => "button", :class => "close", 'data-dismiss' => "alert")
    content << content_tag(:ul, messages.join.html_safe)
    content_tag(:div, content.html_safe, :class => 'alert alert-block')
  end
end
