# frozen_string_literal: true

class RequestDistribution < ApplicationRecord
  # Validations
  validates :area, numericality: { greater_than: 0 }

  validates :pot_quantity, presence: true, if: -> { pot.present? }

  validate :plant_stage_from_request,
           :distributions_areas_lower_than_bench_area

  # Associations
  belongs_to :request,
             class_name: 'Request',
             inverse_of: :request_distributions

  belongs_to :bench,
             class_name: 'Bench',
             inverse_of: :request_distributions

  belongs_to :plant_stage,
             class_name: 'PlantStage',
             inverse_of: :request_distributions

  belongs_to :pot,
             class_name: 'Pot',
             inverse_of: :request_distributions,
             optional: true

  # Private instance methods

  private

  def plant_stage_from_request
    return if request.plant.nil?
    return if request.plant.plant_stages.include?(plant_stage)

    errors.add(:plant_stage, 'must be from requested plant')
  end

  def distributions_areas_lower_than_bench_area
    return if area.nil?
    return if bench&.dimensions.nil?

    bench_area = bench.dimensions.inject(:*)
    sum = bench.request_distributions.sum(&:area)
    sum += area if new_record? # area isn't included in previous operation if record isn't persisted
    return if sum <= bench_area

    errors.add(:bench, 'sum of distributions areas can\'t be greater than bench area')
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
