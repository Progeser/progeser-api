# frozen_string_literal: true

class RequestDistribution < ApplicationRecord
  # Validations
  include ValidateDimensionsConcern
  include ValidatePositionsConcern

  validates :pot_quantity, presence: true, numericality: { greater_than: 0 }

  validate :plant_stage_from_request

  validate :validate_seeds_left_to_plant, on: %i[create update]

  validate :overlapping_distribution_exists, on: %i[create update]

  validate :distribution_within_bench_bounds, on: %i[create update]

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
             inverse_of: :request_distributions

  # Private instance methods

  def validate_seeds_left_to_plant
    return if errors[:pot_quantity].any?

    quantity_change = pot_quantity - (pot_quantity_was || 0)

    total_pot_quantity = request.request_distributions.where.not(id:).sum(:pot_quantity)

    return if request.quantity >= quantity_change + total_pot_quantity

    errors.add(:pot_quantity, 'not enough seeds left to plant for this request')
  end

  private

  def plant_stage_from_request
    return if request.plant.nil?
    return if request.plant.plant_stages.include?(plant_stage)

    errors.add(:plant_stage, 'must be from requested plant')
  end

  def overlapping_distribution_exists
    return if errors[:dimensions].any? || errors[:standardized_positions].any?
    return unless bench

    if bench.request_distributions.any? do |other_distribution|
      next if other_distribution == self

      positions_overlap?(other_distribution)
    end
      errors.add(:positions_on_bench, 'distribution overlaps with an existing distribution')
    end
  end

  def positions_overlap?(other_distribution)
    x1, y1 = positions_on_bench
    width1, height1 = dimensions
    x2, y2 = other_distribution.positions_on_bench
    width2, height2 = other_distribution.dimensions

    x1 < x2 + width2 && x1 + width1 > x2 && y1 < y2 + height2 && y1 + height1 > y2
  end

  def distribution_within_bench_bounds
    return if errors[:dimensions].any? || errors[:standardized_positions].any?
    return unless bench

    bench_dimensions = bench.dimensions
    x, y = positions_on_bench
    width, height = dimensions

    return unless x + width > bench_dimensions[0] || y + height > bench_dimensions[1]

    errors.add(:positions_on_bench, 'distribution exceeds the bounds of the bench')
  end
end

# == Schema Information
#
# Table name: request_distributions
#
#  id                 :bigint           not null, primary key
#  request_id         :bigint
#  bench_id           :bigint
#  plant_stage_id     :bigint
#  pot_id             :bigint
#  pot_quantity       :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  positions_on_bench :integer          is an Array
#  dimensions         :integer          is an Array
#
# Indexes
#
#  index_request_distributions_on_bench_id        (bench_id)
#  index_request_distributions_on_plant_stage_id  (plant_stage_id)
#  index_request_distributions_on_pot_id          (pot_id)
#  index_request_distributions_on_request_id      (request_id)
#
