require_dependency 'application'

class AccountManagerExtension < Radiant::Extension
  version "1.0"
  description "Customer Account Management System"
  url "http://webwideconsulting.com"
  
  define_routes do |map|
    map.connect 'admin/accounts/:action/:id', :controller => 'admin/account_manager'
    map.connect 'account/:action', :controller => 'account_manager'
    map.connect 'login', :controller => 'sessions', :action => 'new'
    map.connect 'logout', :controller => 'sessions', :action => 'destroy'
    map.connect 'forgot_password', :controller => 'account_manager', :action => 'forgot_password'
    map.change_password 'change_password', :controller => 'account_manager', :action => 'change_password'
    map.resource :session
    map.resource :account, :controller => 'account_manager'
    map.admin_mailer '/admin/mailer/:action/', :controller => 'admin/mailer'
  end
  
  def activate
    # admin.tabs.add "Customers", "/admin/account_manager", :after => "Layouts", :visibility => [:all]
    admin.tabs.add "Mailer", "/admin/mailer", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Customers"
  end
  
end