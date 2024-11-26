# frozen_string_literal: true

class AddLaboratoryAndPasswordToAccountRequests < ActiveRecord::Migration[7.2]
  def change
    change_table :account_requests, bulk: true do |t|
      t.string :laboratory
      t.string :password_digest
    end
  end
end
