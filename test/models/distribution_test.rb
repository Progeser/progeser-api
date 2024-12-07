# frozen_string_literal: true

require 'test_helper'

class DistributionTest < ActiveSupport::TestCase
  # Setups
  def setup
    @distribution = distributions(:distribution1)
    @request_distribution = request_distributions(:request_distribution1)
    @bench = benches(:bench1)
    @pot = pots(:pot1)
  end

  test 'invalid without seed quantity' do
    @distribution.seed_quantity = nil
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:seed_quantity], 'doit être rempli(e)'
  end

  test 'invalid with non-positive seed quantity' do
    @distribution.seed_quantity = -1
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:seed_quantity], 'doit être supérieur à 0'

    @distribution.seed_quantity = 0
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:seed_quantity], 'doit être supérieur à 0'
  end

  test 'invalid without dimensions' do
    @distribution.dimensions = nil
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:dimensions], 'doit être rempli(e)'
  end

  test 'invalid with wrong number of dimensions' do
    @distribution.dimensions = [10]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:dimensions], 'doit contenir exactement deux éléments: longueur et largeur'

    @distribution.dimensions = [10, 20, 30]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:dimensions], 'doit contenir exactement deux éléments: longueur et largeur'
  end

  test 'invalid with non-positive dimensions' do
    @distribution.dimensions = [10, -20]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:dimensions], 'each dimension must be greater than 0'

    @distribution.dimensions = [0, 30]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:dimensions], 'each dimension must be greater than 0'
  end

  test 'invalid without position' do
    @distribution.positions_on_bench = nil
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:positions_on_bench], 'doit être rempli(e)'
  end

  test 'invalid with wrong number of positions_on_bench' do
    @distribution.positions_on_bench = [10]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:positions_on_bench], 'doit contenir exactement deux éléments : x et y'

    @distribution.positions_on_bench = [10, 20, 30]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:positions_on_bench], 'doit contenir exactement deux éléments : x et y'
  end

  test 'invalid with negative position' do
    @distribution.positions_on_bench = [10, -20]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:positions_on_bench], 'each position must be positive'

    @distribution.positions_on_bench = [-1, 0]
    assert_not @distribution.valid?
    assert_includes @distribution.errors[:positions_on_bench], 'each position must be positive'
  end

  test 'invalid since there are not enough seeds left' do
    distribution = Distribution.new(
      request_distribution: @request_distribution,
      bench: @bench,
      pot: @pot,
      positions_on_bench: [5, 5],
      dimensions: [10, 20],
      seed_quantity: 100
    )

    assert_not distribution.valid?
    assert_includes distribution.errors[:seed_quantity], 'not enough seeds left to plant for this request'
  end

  test 'invalid when overlapping with another distribution in the same bench' do
    overlapping_distribution = Distribution.new(
      request_distribution: @request_distribution,
      bench: @bench,
      pot: @pot,
      positions_on_bench: [0, 0],
      dimensions: [10, 20],
      seed_quantity: 100
    )

    assert_not overlapping_distribution.valid?
    assert_includes overlapping_distribution.errors[:positions_on_bench], 'distribution overlaps with an existing distribution'
  end

  test 'invalid when distribution outside bench' do
    distribution = Distribution.new(
      request_distribution: @request_distribution,
      bench: @bench,
      pot: @pot,
      positions_on_bench: [500, 500],
      dimensions: [10, 20],
      seed_quantity: 100
    )

    assert_not distribution.valid?
    assert_includes distribution.errors[:positions_on_bench], 'distribution exceeds the bounds of the bench'

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
