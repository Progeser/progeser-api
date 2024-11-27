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
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :role,
            :type,
            :first_name,
            :last_name,
            presence: true

  # Associations
  has_many :access_tokens, # rubocop:disable Rails/InverseOf
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :authored_requests,
           class_name: 'Request',
           foreign_key: 'author_id',
           inverse_of: :author,
           dependent: :destroy

  after_discard :anonymize

  validates :password, presence: true, confirmation: true, on: :create, unless: :skip_password_validation?

  def skip_password_validation?
    encrypted_password.present?
  end

  # Public instance methods
  def create_token!
    Doorkeeper::AccessToken.create!(
      resource_owner_id: id,
      use_refresh_token: true,
      expires_in: Doorkeeper.configuration.access_token_expires_in
    )
  end

  def update_password!(password:, password_confirmation:)
    if password != password_confirmation
      errors.add(:password_confirmation, :confirmation, attribute: 'Password')
      raise ActiveRecord::RecordInvalid, self
    end

    update_password(password)
  end

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
