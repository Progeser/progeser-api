class CreateAccountRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :account_requests do |t|
      t.string :email, null: false
      t.string :creation_token, null: false
      t.string :first_name
      t.string :last_name
      t.text :comment
      t.boolean :accepted, null: false, default: false

      t.timestamps
    end

    add_index :account_requests, :email, unique: true
    add_index :account_requests, :creation_token, unique: true
  end
end
