# -*- coding: utf-8 -*-
module ApplicationHelper
  def title
    @title ||= t(:title, :subject => subject,
                 :scope => [controller_name, action_name], :default => controller_name)
  end

  def subject
    return unless %w(edit show view index).include?(action_name)
    return unless instance = controller.instance_variable_get("@#{controller_name.singularize}")
    return unless instance.respond_to?(:name)
    instance.name
  end

  def flashy
    css, message = nil, nil

    if msg = flash[:notice] || params[:notice]
      css, message = 'alert-success', msg
    elsif msg = flash[:error] || params[:error]
      css, message = 'alert alert-error', msg
    elsif msg = flash[:warning] || params[:warning]
      css, message = 'alert alert-info', msg
    elsif msg = flash[:alert] || params[:alert]
      css, message = 'alert alert-error', msg
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
