class Notifier < ActionMailer::Base
  default_url_options[:host] = "coder.mn"
  
  def password_reset_instructions(user)
    subject       "Нууц үг сэргээх заавар"
    from          "Coder.mn <no-reply@coder.mn>"
    reply_to      "Coder.mn <no-reply@coder.mn>"
    recipients    user.email
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token),
                  :login => user.login
  end

  def release_notification(user)
    subject       "Кодер.мн шинэчлэгдлээ"
    from          "Coder.mn <no-reply@coder.mn>"
    reply_to      "Coder.mn <no-reply@coder.mn>"
    bcc           "coder.mn@gmail.com"
    recipients    user.email
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token),
                  :login => user.login
  end

end
