# frozen_string_literal: true

class RequestDistribution < ApplicationRecord
  # Validations
  validates :area, numericality: { greater_than: 0 }

  validates :pot_quantity, presence: true, if: -> { pot.present? }

  validate :plant_stage_from_request

  # Associations
  belongs_to :request,
             class_name: 'Request',
             foreign_key: 'request_id',
             inverse_of: :request_distributions

  belongs_to :bench,
             class_name: 'Bench',
             foreign_key: 'bench_id',
             inverse_of: :request_distributions

  belongs_to :plant_stage,
             class_name: 'PlantStage',
             foreign_key: 'plant_stage_id',
             inverse_of: :request_distributions

  belongs_to :pot,
             class_name: 'Pot',
             foreign_key: 'pot_id',
             inverse_of: :request_distributions,
             optional: true

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
#  bench_id       :bigint
#  plant_stage_id :bigint
#  pot_id         :bigint
#  pot_quantity   :integer
#  area           :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_request_distributions_on_bench_id        (bench_id)
#  index_request_distributions_on_plant_stage_id  (plant_stage_id)
#  index_request_distributions_on_pot_id          (pot_id)
#  index_request_distributions_on_request_id      (request_id)
#
