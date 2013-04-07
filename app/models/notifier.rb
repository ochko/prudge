# -*- coding: utf-8 -*-
class Notifier < ActionMailer::Base
  default_url_options[:host] = "coder.query.mn"
  
  def password_reset_instructions(user)
    user_notify(user, "Нууц үг сэргээх заавар")
  end

  def release_notification(user)
    user_notify(user, "Кодер шинэчлэгдлээ")
  end

  def problem_selection(user, contest, problem)
    compose(user, "Таны дэвшүүлсэн бодлого тэмцээнд сонгогдлоо",
            :problem_url => problem_url(problem),
            :contest_url => contest_url(contest),
            :problem => problem, 
            :contest => contest)
  end

  def new_contest(user, contest)
    contest_notify(user, contest, "Кодер дээр Шинэ тэмцээн зарлагдлаа")
  end

  def contest_update(user, contest)
    contest_notify(user, contest, "Кодер дээр тэмцээнд өөрчлөлт орлоо")
  end

  private

  def user_notify(user, title)
    compose(user, title, 
            :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def contest_notify(user, contest, title)
    compose(user, title, 
            :contest => contest,
            :contest_url => contest_url(contest))
  end

  def compose(user, title, options)
    subject       title
    from          "coder.mn@gmail.com"
    recipients    user.email
    sent_on       Time.now  
    body          options.merge(:login => user.login)
  end

end
