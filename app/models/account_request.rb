# frozen_string_literal: true

class AccountRequest < ApplicationRecord
  has_secure_token :creation_token
  has_secure_password

  # Validations
  validates :email,
            presence: true,
            uniqueness: true,
            email: { message: :email_invalid }

  validates :first_name,
            :last_name,
            presence: true

  validates :accepted, inclusion: { in: [true, false] }
  validates :laboratory, presence: false, allow_nil: true
end

# == Schema Information
#
# Table name: account_requests
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  creation_token  :string           not null
#  first_name      :string
#  last_name       :string
#  comment         :text
#  accepted        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  laboratory      :string
#  password_digest :string
#
# Indexes
#
#  index_account_requests_on_creation_token  (creation_token) UNIQUE
#  index_account_requests_on_email           (email) UNIQUE
#
