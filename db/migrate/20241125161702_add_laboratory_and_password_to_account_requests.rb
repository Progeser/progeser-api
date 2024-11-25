class AddLaboratoryAndPasswordToAccountRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :account_requests, :laboratory, :string
    add_column :account_requests, :password_digest, :string
  end
end
