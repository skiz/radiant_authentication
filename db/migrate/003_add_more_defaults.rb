class AddMoreDefaults < ActiveRecord::Migration
  def self.up
    add_column :accounts, :default_csa_id, :integer
    add_column :accounts, :default_billing_address_id, :integer
  end
    
  def self.down
    remove_column :accounts, :default_billing_address_id
    remove_column :accounts, :default_csa_id
  end
end
