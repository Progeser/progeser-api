# frozen_string_literal: true

class Plant < ApplicationRecord
  # Validations
  validates :name, presence: true

  # Associations
  has_many :plant_stages,
           -> { order(position: :asc) },
           class_name: 'PlantStage',
           foreign_key: 'plant_id',
           inverse_of: :plant,
           dependent: :destroy
end

# == Schema Information
#
# Table name: plants
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
