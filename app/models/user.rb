# frozen_string_literal: true

class User < ApplicationRecord
  # Clearance
  include Clearance::User

  # Discard
  include Discard::Model

  # Validations
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password,
            presence: true,
            confirmation: true,
            on: :create

  validates :password_confirmation,
            presence: true,
            on: :create

  validates :first_name,
            :last_name,
            presence: true

  # Associations
  has_many :access_tokens, # rubocop:disable Rails/InverseOf
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :handled_requests,
           class_name: 'Request',
           foreign_key: 'handler_id',
           inverse_of: :handler,
           dependent: :destroy

  # Callbacks
  after_discard :partial_anonymize

  # check password_confirmation before using `update_password` method from Clearance::User
  #
  def update_password!(password:, password_confirmation:)
    if password != password_confirmation
      errors.add(:password_confirmation, :confirmation, attribute: 'Password')
      raise ActiveRecord::RecordInvalid, self
    end

    update_password(password)
  end

  private

  def partial_anonymize
    self.email              = "anonymized_#{id}"
    self.encrypted_password = 'anonymized'
    self.confirmation_token = nil
    self.remember_token     = 'anonymized'

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
#  first_name         :string           not null
#  last_name          :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#
# Indexes
#
#  index_users_on_discarded_at    (discarded_at)
#  index_users_on_email           (email) UNIQUE
#  index_users_on_remember_token  (remember_token)
#
