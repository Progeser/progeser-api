# frozen_string_literal: true

class Distribution < ApplicationRecord
  validates :seed_quantity, presence: true, numericality: { greater_than: 0 }

  validates :dimensions,
            presence: true,
            length: { is: 2, message: I18n.t('activerecord.errors.models.bench.attributes.dimensions.incorrect_size') }
  validate :dimensions_must_be_strictly_positive

  validates :positions_on_bench,
            presence: true,
            length: { is: 2, message: I18n.t('activerecord.errors.models.bench.attributes.positions.incorrect_size') }
  validate :positions_must_be_positive

  validate :validate_seeds_left_to_plant, on: %i[create update]

  validate :overlapping_distribution_exists, on: %i[create update]

  validate :distribution_within_bench_bounds, on: %i[create update]

  # Associations
  belongs_to :bench,
             class_name: 'Bench',
             inverse_of: :distributions

  belongs_to :request_distribution,
             class_name: 'RequestDistribution',
             inverse_of: :distributions

  belongs_to :pot,
             class_name: 'Pot',
             inverse_of: :distributions,
             optional: true

  after_create :decrement_seeds_left_to_plant
  before_update :update_seeds_left_to_plant, if: :will_save_change_to_seed_quantity?
  before_destroy :increase_seeds_left_to_plant

  private

  def increase_seeds_left_to_plant
    request_distribution.seeds_left_to_plant += seed_quantity
    request_distribution.save
  end

  def decrement_seeds_left_to_plant
    request_distribution.seeds_left_to_plant -= seed_quantity
    request_distribution.save
  end

  def update_seeds_left_to_plant
    change_in_quantity = seed_quantity - seed_quantity_was
    request_distribution.seeds_left_to_plant -= change_in_quantity
    request_distribution.save
  end

  def validate_seeds_left_to_plant
    return if errors[:seed_quantity].any?

    quantity_change = seed_quantity - (seed_quantity_was || 0)

    return if request_distribution.seeds_left_to_plant >= quantity_change

    errors.add(:seed_quantity, 'not enough seeds left to plant for this request')
  end

  def dimensions_must_be_strictly_positive
    return unless dimensions

    return unless dimensions.any? { |d| d <= 0 }

    errors.add(:dimensions, 'each dimension must be greater than 0')
  end

  def positions_must_be_positive
    return unless positions_on_bench

    return unless positions_on_bench.any?(&:negative?)

    errors.add(:positions_on_bench, 'each position must be positive')
  end

  def overlapping_distribution_exists
    return if errors[:dimensions].any? || errors[:positions_on_bench].any?
    return unless bench

    if bench.distributions.any? do |other_distribution|
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
    return if errors[:dimensions].any? || errors[:positions_on_bench].any?
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
# Table name: distributions
#
#  id                      :bigint           not null, primary key
#  request_distribution_id :bigint
#  bench_id                :bigint
#  pot_id                  :bigint
#  positions_on_bench      :integer          is an Array
#  dimensions              :integer          is an Array
#  seed_quantity           :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_distributions_on_bench_id                 (bench_id)
#  index_distributions_on_pot_id                   (pot_id)
#  index_distributions_on_request_distribution_id  (request_distribution_id)
#
