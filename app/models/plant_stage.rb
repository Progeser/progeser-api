# frozen_string_literal: true

class PlantStage < ApplicationRecord
  # ActsAsList
  acts_as_list scope: :plant

  # Validations
  validates :name, presence: true

  validates :position,
            :duration,
            numericality: { greater_than: 0 }

  # Associations
  belongs_to :plant,
             class_name: 'Plant',
             foreign_key: 'plant_id',
             inverse_of: :plant_stages

  has_many :requests,
           class_name: 'Request',
           foreign_key: 'plant_stage_id',
           inverse_of: :plant_stage,
           dependent: :destroy

  has_many :request_distributions,
           class_name: 'RequestDistribution',
           foreign_key: 'plant_stage_id',
           inverse_of: :plant_stage,
           dependent: :destroy
end

# == Schema Information
#
# Table name: plant_stages
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  duration   :integer
#  position   :integer          not null
#  plant_id   :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_plant_stages_on_plant_id  (plant_id)
#
