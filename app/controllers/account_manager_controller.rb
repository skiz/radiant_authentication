class AccountManagerController < ApplicationController
  include AuthenticatedSystem
  include SslRequirement
  ssl_required :change_password, :forgot_password
  
  radiant_layout 'Default'

  no_login_required
  skip_before_filter :verify_authenticity_token
  
  before_filter :login_required, :except => 'forgot_password'

  # Default information page
  def index
    @account = current_user
  end
  
  # changes the users default csa
  def update_default_csa
    @account = Account.find_by_login(current_user.login)
    @account.update_attribute(:default_csa_id, params[:default_csa])
    flash[:notice] = "Your default delivery location has been updated."
    redirect_to '/account'
  end
  
  # Allows user to change their current password
  def change_password
     return unless request.post?
     if @account = Account.authenticate(current_user.login, params[:old_password])
       if (params[:password] == params[:password_confirmation])
         @account.password = params[:password]
         @account.password_confirmation = params[:password_confirmation]
         if @account.save
           flash[:notice] = 'Your password has been changed, please note it somewhere safe.'
           redirect_to '/account'
         else
           flash.now[:notice] = "Password " << @account.errors.on(:password)
         end
       else         
         @old_password = params[:old_password]
       end
     else
       flash.now[:notice] = "Wrong password" 
     end
   end
  
  # Allows user to edit their account information
  def edit
    @account = current_user
  end
  
  # Updates the user's information
  def update
    @account = Account.find_by_id(current_user.id)
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Your profile was successfully updated.'
      redirect_to '/account'
    else
      flash.now[:notice] = 'We were unable to update our records, please check for any errors and try again.'
      render :action => "edit"
    end
  end
  
  def forgot_password
    if request.post? && params[:email]
      account = Account.find_by_email(params[:email])
      if account
        @email = account.email
        new_pass = Account.generate_password
        account.password, account.password_confirmation = new_pass
        account.save(false)
        account.password = new_pass #becuase its removed on save
        AccountNotifier.deliver_forgot_password_notification(account, new_pass) 
        flash.now[:notice] = "We have sent an email to #{@email} containing your new information."
      else
        flash.now[:notice] = "Unable to locate an account for that address."
      end
    end
  end
  

end
