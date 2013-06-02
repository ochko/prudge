# -*- coding: utf-8 -*-
class Notifier < ActionMailer::Base
  default :from => Settings.notifier
  
  def password_reset_instructions(user)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)

    compose user
  end

  def password_reset_confirmation(user)
    @forgot_password_url = forgot_password_url

    compose user
  end

  def release_notification(user)
    @login_url = login_url

    compose user
  end

  def problem_selection(user, contest, problem)
    @problem_url = problem_url(problem)
    @contest_url = contest_url(contest)
    @problem = problem
    @contest = contest

    compose user
  end

  def new_contest(user, contest)
    contest_notify(user, contest)
  end

  def contest_update(user, contest)
    contest_notify(user, contest)
  end

  private

  def contest_notify(user, contest)
    @contest = contest
    @contest_url = contest_url(contest)

    compose(user, :contest => @contest.name)
  end

  def compose(user, options = {})
    @login = user.login
    
    mail(:to => user.email,
         :subject => localized_subject(options))
  end

  def localized_subject(options)
    I18n.t(:subject,
           { :scope => [:notifier, action_name],
             :site => Settings.name }.merge(options) )
    
  end
end
