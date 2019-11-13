# frozen_string_literal: true

class AccountRequest < ApplicationRecord
  has_secure_token :creation_token

  # Validations
  validates :email,
            presence: true,
            uniqueness: true,
            email: { message: :email_invalid }

  validates :first_name,
            :last_name,
            presence: true
end

# == Schema Information
#
# Table name: account_requests
#
#  id             :bigint           not null, primary key
#  email          :string           not null
#  creation_token :string           not null
#  first_name     :string
#  last_name      :string
#  comment        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_account_requests_on_creation_token  (creation_token) UNIQUE
#  index_account_requests_on_email           (email) UNIQUE
#
