# frozen_string_literal: true

class AddUniqueIndexOnEmailToUsers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    remove_index :users, :email
    add_index :users, :email, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :users, :email
    add_index :users, :email, algorithm: :concurrently
  end
end
