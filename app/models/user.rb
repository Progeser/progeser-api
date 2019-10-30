# frozen_string_literal: true

class User < ApplicationRecord
  # Enumerize
  extend Enumerize
  enumerize :role,
            in: %i[requester grower]

  # Validations
  validates :email,
            presence: true,
            uniqueness: true,
            email: {message: :email_invalid}

  # Associations
  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  role               :string
#  last_name          :string
#  first_name         :string
#  type               :string
#  laboratory         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email           (email)
#  index_users_on_remember_token  (remember_token)
#
