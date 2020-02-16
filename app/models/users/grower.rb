# frozen_string_literal: true

class Users::Grower < User
  # Associations
  has_many :handled_requests,
           class_name: 'Request',
           foreign_key: 'handler_id',
           inverse_of: :handler,
           dependent: :destroy
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
