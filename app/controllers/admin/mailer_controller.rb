class Admin::MailerController < ApplicationController

  before_filter :require_recipients, :only => :index
  
  # display a mailer that can be used for creating custom emails to customers
  def index
    setup_recipients
    @footer = "West Coast Distribution Support Services - support@realfoodbayarea.com"
  end

  # choose a csa, 
  def select_recipients
    if request.post?
      if params[:csa]
        session[:mail_recipients] = {:csa => params[:csa]}
      end
      if params[:account]
        session[:mail_recipients] = {:account => params[:account]}
      end
      redirect_to :action => 'index'
    end
  end
  
  # send the message
  def fire
    setup_recipients
    
    # too many for a single email, lets do this instead....
    @recipients.in_groups_of(20).each do |grp|
      grp.reject!{|l| l.nil?}
      AccountNotifier.deliver_administration_email(grp, params[:subject], params[:message], params[:footer])
    end
    session[:mail_recipients] = nil
    flash[:notice] = "Successfully sent email"
    redirect_to '/admin' and return
  end
  
  # clear the mail_recipients session and send them back to admin
  def cancel
    flash[:notice] = "Mail Message has been canceled."
    session[:mail_recipients] = nil
    redirect_to '/admin'
  end
  
  protected
  
  def require_recipients
    if session[:mail_recipients].blank?
      redirect_to :action => :select_recipients
    end
  end
  
  def setup_recipients
    @recipients = []
    if session[:mail_recipients].keys.include?(:csa)
      ids = session[:mail_recipients][:csa]
      @recipients << Account.find(:all, :conditions => ['default_csa_id IN (?)', ids])
    end
    if session[:mail_recipients].keys.include?(:account)
      ids = session[:mail_recipients][:account]
      @recipients << Account.find(:all, :conditions => ['id IN (?)', ids])
    end
    @recipients.flatten!.uniq!
  end
  
end