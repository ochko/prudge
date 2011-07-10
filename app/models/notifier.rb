# -*- coding: utf-8 -*-
class Notifier < ActionMailer::Base
  default_url_options[:host] = "coder.query.mn"
  
  def password_reset_instructions(user)
    subject       "Нууц үг сэргээх заавар"
    from          "coder.mn@gmail.com"
    recipients    user.email
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token),
                  :login => user.login
  end

  def release_notification(user)
    subject       "Кодер шинэчлэгдлээ"
    from          "coder.mn@gmail.com"
    recipients    user.email
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token),
                  :login => user.login
  end

  def problem_selection(user, contest, problem)
    subject       "Та бодлого тэмцээнд сонгогдлоо"
    from          "coder.mn@gmail.com"
    recipients    user.email
    sent_on       Time.now  
    body          :problem_url => problem_url(problem),
                  :contest_url => contest_url(contest),
                  :problem => problem, 
                  :contest => contest,
                  :login => user.login
  end

end
