# frozen_string_literal: true

class User < ApplicationRecord
  # Clearance
  include Clearance::User

  # Discard
  include Discard::Model

  # Enumerize
  extend Enumerize
  enumerize :role,
            in: %i[requester grower],
            predicates: true

  # Validations
  validates :email,
            presence: true,
            uniqueness: true,
            email: { message: :email_invalid }

  validates :password,
            presence: true,
            confirmation: true,
            on: :create

  validates :password_confirmation,
            presence: true,
            on: :create

  validates :role,
            :type,
            :first_name,
            :last_name,
            presence: true

  # Associations
  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  # Callbacks
  after_discard :anonymize

  # Private instance methods
  private

  def anonymize
    self.email              = "anonymized_#{id}"
    self.encrypted_password = 'anonymized'
    self.confirmation_token = nil
    self.remember_token     = 'anonymized'
    self.first_name         = nil
    self.last_name          = nil
    self.laboratory         = nil

    save(validate: false)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  role               :string
#  first_name         :string
#  last_name          :string
#  type               :string
#  laboratory         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#
# Indexes
#
#  index_users_on_discarded_at    (discarded_at)
#  index_users_on_email           (email)
#  index_users_on_remember_token  (remember_token)
#
