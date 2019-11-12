# frozen_string_literal: true

class Invite < ApplicationRecord
  has_secure_token :invitation_token

  # Enumerize
  extend Enumerize
  enumerize :role,
            in: User.role.values.map(&:to_sym),
            predicates: true

  # Validations
  validates :email,
            presence: true,
            uniqueness: true,
            email: { message: :email_invalid }

  validates :role,
            :first_name,
            :last_name,
            presence: true

  validates :laboratory,
            presence: true,
            if: :requester?
end

# == Schema Information
#
# Table name: invites
#
#  id               :bigint           not null, primary key
#  email            :string           not null
#  invitation_token :string           not null
#  role             :string
#  first_name       :string
#  last_name        :string
#  laboratory       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_invites_on_email             (email) UNIQUE
#  index_invites_on_invitation_token  (invitation_token) UNIQUE
#
