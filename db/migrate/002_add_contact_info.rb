class AddContactInfo < ActiveRecord::Migration
  def self.up
    add_column :accounts, :first_name, :string
    add_column :accounts, :last_name, :string
    add_column :accounts, :contact_phone, :string
  end
    
  def self.down
    remove_column :accounts, :contact_phone
    remove_column :accounts, :last_name
    remove_column :accounts, :first_name
  end
end
