# This model is used so customers can log in and manage their account information.
require 'digest/sha1'

require File.dirname(__FILE__) + '/../../lib/authentication'
require File.dirname(__FILE__) + '/../../lib/authentication/by_password'
require File.dirname(__FILE__) + '/../../lib/authentication/by_cookie_token'

class Account < ActiveRecord::Base
  
  has_many :orders do
    def recent(cnt = 5)
      find(:all, :order => 'created_at DESC', :limit => cnt)
    end
  end
  has_many :addresses
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD

  validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :name,     :maximum => 100


  validates_length_of :password, :minimum => 6

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  validates_presence_of :first_name, :last_name, :contact_phone


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :first_name, :last_name, :contact_phone
  attr_accessible :default_csa_id, :default_billing_address_id
  
  belongs_to :default_billing_address, :class_name => 'Address'

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def display_name
    "#{self.first_name} #{self.last_name}"
  rescue
    "Unknown"
  end
  
  # full name + email for sending email
  def email_address_with_name
    "#{email} <#{self.first_name} #{self.last_name}>"
  end
  
  # Just a password generator that matches the auth system requirements
  def self.generate_password
    new_password = ""
    consonants = "bcdfghjklmnprstv"
    vowels = "aeiou"
    
    3.times do
      new_password << consonants[rand(consonants.size-1)]
      new_password << vowels[rand(vowels.size-1)]
    end
    new_password << (rand(89)+10).to_s
    new_password
  end

  protected



end
