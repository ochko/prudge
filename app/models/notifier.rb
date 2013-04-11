# -*- coding: utf-8 -*-
class Notifier < ActionMailer::Base
  default :from => "coder.mn@gmail.com", :host => "coder.query.mn"
  
  def password_reset_instructions(user)
    user_notify(user, "Нууц үг сэргээх заавар")
  end

  def release_notification(user)
    user_notify(user, "Кодер шинэчлэгдлээ")
  end

  def problem_selection(user, contest, problem)
    @problem_url = problem_url(problem)
    @contest_url = contest_url(contest)
    @problem = problem
    @contest = contest

    compose(user, "Таны дэвшүүлсэн бодлого тэмцээнд сонгогдлоо")
  end

  def new_contest(user, contest)
    contest_notify(user, contest, "Кодер дээр Шинэ тэмцээн зарлагдлаа")
  end

  def contest_update(user, contest)
    contest_notify(user, contest, "Кодер дээр тэмцээнд өөрчлөлт орлоо")
  end

  private

  def user_notify(user, title)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)

    compose(user, title)
  end

  def contest_notify(user, contest, title)
    @contest = contest
    @contest_url = contest_url(contest)

    compose(user, title) 
  end

  def compose(user, title)
    @login = user.login

    mail(:subject => title, :to => user.email)
  end

end
