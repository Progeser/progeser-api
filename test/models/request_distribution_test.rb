# frozen_string_literal: true

require 'test_helper'

class RequestDistributionTest < ActiveSupport::TestCase
  # Setups
  def setup
    @request_distribution = request_distributions(:request_distribution1)
    @plant_stage = plant_stages(:plant_stage18)
  end

  # Validations
  test 'valid request_distribution' do
    assert @request_distribution.valid?, @request_distribution.errors.messages
  end

  test 'invalid without bench' do
    @request_distribution.bench = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:bench]
  end

  test 'invalid without pot' do
    @request_distribution.pot = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:pot]
  end

  test 'invalid without pot quantity' do
    @request_distribution.pot_quantity = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:pot_quantity]
  end

  test 'invalid wit pot quantity lee than 0' do
    @request_distribution.pot_quantity = -1
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:pot_quantity]

    @request_distribution.pot_quantity = 0
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:pot_quantity]
  end

  test 'invalid without plant_stage' do
    @request_distribution.plant_stage = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:plant_stage]
  end

  test 'invalid with plant_stage from the non-requested plant' do
    @request_distribution.plant_stage = PlantStage.last
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:plant_stage]
  end

  test 'invalid without enough seeds left to plant' do
    @request_distribution.pot_quantity = 500
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:pot_quantity]
  end

  test 'invalid without dimensions' do
    @request_distribution.dimensions = nil
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:dimensions], 'doit être rempli(e)'
  end

  test 'invalid with wrong number of dimensions' do
    @request_distribution.dimensions = [10]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:dimensions],
                    'doit contenir exactement deux éléments: longueur et largeur'

    @request_distribution.dimensions = [10, 20, 30]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:dimensions],
                    'doit contenir exactement deux éléments: longueur et largeur'
  end

  test 'invalid with non-positive dimensions' do
    @request_distribution.dimensions = [10, -20]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:dimensions], 'each dimension must be greater than 0'

    @request_distribution.dimensions = [0, 30]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:dimensions], 'each dimension must be greater than 0'
  end

  test 'invalid without positions_on_bench' do
    @request_distribution.positions_on_bench = nil
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:positions_on_bench], 'doit être rempli(e)'
  end

  test 'invalid with wrong number of positions_on_bench' do
    @request_distribution.positions_on_bench = [10]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:positions_on_bench], 'doit contenir exactement deux éléments : x et y'

    @request_distribution.positions_on_bench = [10, 20, 30]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:positions_on_bench], 'doit contenir exactement deux éléments : x et y'
  end

  test 'invalid with non-positive positions_on_bench' do
    @request_distribution.positions_on_bench = [10, -20]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:positions_on_bench], 'each position must be positive'

    @request_distribution.positions_on_bench = [-1, 30]
    assert_not @request_distribution.valid?
    assert_includes @request_distribution.errors[:positions_on_bench], 'each position must be positive'
  end

  test 'invalid when overlapping with another distribution in the same bench' do
    overlapping_distribution = RequestDistribution.new(
      request: Request.first,
      bench: Bench.first,
      pot: Pot.first,
      plant_stage: @plant_stage,
      pot_quantity: 10,
      positions_on_bench: [0, 0],
      dimensions: [10, 20]
    )

    assert_not overlapping_distribution.valid?
    assert_includes overlapping_distribution.errors[:positions_on_bench],
                    'distribution overlaps with an existing distribution'
  end

  test 'invalid when distribution outside bench' do
    distribution = RequestDistribution.new(
      request: Request.first,
      bench: Bench.first,
      pot: Pot.first,
      plant_stage: @plant_stage,
      pot_quantity: 10,
      positions_on_bench: [1000, 1000],
      dimensions: [10, 20]
    )

    assert_not distribution.valid?
    assert_includes distribution.errors[:positions_on_bench], 'distribution exceeds the bounds of the bench'
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
