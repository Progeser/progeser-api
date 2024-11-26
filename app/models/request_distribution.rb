# frozen_string_literal: true

class RequestDistribution < ApplicationRecord
  # Validations
  validate :plant_stage_from_request

  # Associations
  belongs_to :request,
             class_name: 'Request',
             inverse_of: :request_distributions

  belongs_to :plant_stage,
             class_name: 'PlantStage',
             inverse_of: :request_distributions

  has_many :distributions,
           class_name: 'Distribution',
           inverse_of: :request_distribution,
           dependent: :destroy

  # Private instance methods

  private

  def plant_stage_from_request
    return if request.plant.nil?
    return if request.plant.plant_stages.include?(plant_stage)

    errors.add(:plant_stage, 'must be from requested plant')
  end
end

# == Schema Information
#
# Table name: request_distributions
#
#  id             :bigint           not null, primary key
#  request_id     :bigint
#  plant_stage_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_request_distributions_on_plant_stage_id  (plant_stage_id)
#  index_request_distributions_on_request_id      (request_id)
#
