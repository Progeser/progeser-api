# frozen_string_literal: true

class Building < ApplicationRecord
  # Associations
  has_many :greenhouses, dependent: :destroy

  # Validations
  validates :name, presence: true
end

# == Schema Information
#
# Table name: buildings
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
