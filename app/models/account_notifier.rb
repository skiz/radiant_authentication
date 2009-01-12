class AccountNotifier < ActionMailer::Base
  def forgot_password_notification(recipient, password)
    recipients recipient.email
    from       "support@realfoodbayarea.com"
    subject    default_subject + "Your Account Information"
    body       :account => recipient, :password => password
  end
  
  def administration_email(recipients, subject, message, footer)
    recipients "support@realfoodbayarea.com"
    bcc        recipients.map(&:email)
    from       "support@realfoodbayarea.com"
    subject    default_subject + subject
    body       :message => message, :footer => footer
  end
  
  
  protected
  
    def default_subject
      "RealFoodBayArea.com - "
    end
end
