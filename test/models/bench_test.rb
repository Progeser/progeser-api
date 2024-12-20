# frozen_string_literal: true

require 'test_helper'

class BenchTest < ActiveSupport::TestCase
  # Setups
  def setup
    @bench = benches(:bench1)
  end

  # Validations
  test 'valid bench' do
    assert @bench.valid?, @bench.errors.messages
  end

  test 'valid without name' do
    @bench.name = nil
    assert @bench.valid?, @bench.errors.messages
  end

  test 'invalid without dimensions' do
    @bench.dimensions = nil
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'doit être rempli(e)'
  end

  test 'invalid with wrong number of dimensions' do
    @bench.dimensions = [10]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'doit contenir exactement deux éléments: longueur et largeur'

    @bench.dimensions = [10, 20, 30]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'doit contenir exactement deux éléments: longueur et largeur'
  end

  test 'invalid with non-positive dimensions' do
    @bench.dimensions = [10, -20]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'chaque dimension doit être supérieure à 0'

    @bench.dimensions = [0, 30]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'chaque dimension doit être supérieure à 0'
  end

  test 'invalid without position' do
    @bench.positions = nil
    assert_not @bench.valid?
    assert_includes @bench.errors[:standardized_positions], 'doit être rempli(e)'
  end

  test 'invalid with negative position' do
    @bench.positions = [10, -20]
    assert_not @bench.valid?
    assert_includes @bench.errors[:standardized_positions], 'chaque position doit être positive'

    @bench.positions = [-1, 0]
    assert_not @bench.valid?
    assert_includes @bench.errors[:standardized_positions], 'chaque position doit être positive'
  end

  test 'invalid with wrong number of positions' do
    @bench.positions = [10]
    assert_not @bench.valid?
    assert_includes @bench.errors[:standardized_positions], 'doit contenir exactement deux éléments : x et y'

    @bench.positions = [10, 20, 30]
    assert_not @bench.valid?
    assert_includes @bench.errors[:standardized_positions], 'doit contenir exactement deux éléments : x et y'
  end

  test 'invalid when distributions areas is lower than bench area' do
    @bench.dimensions = [10, 20]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'sum of distributions areas can\'t be greater than bench area'
  end

  test 'invalid when overlapping with another bench in the same greenhouse' do
    overlapping_bench = Bench.new(
      greenhouse: @bench.greenhouse,
      name: 'my test',
      positions: @bench.positions,
      dimensions: [50, 20]
    )
    assert_not overlapping_bench.valid?
    assert_includes overlapping_bench.errors[:positions], 'bench overlaps with an existing bench'
  end
end

# == Schema Information
#
# Table name: benches
#
#  id            :bigint           not null, primary key
#  greenhouse_id :bigint
#  name          :string
#  dimensions    :integer          is an Array
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  positions     :integer          is an Array
#
# Indexes
#
#  index_benches_on_greenhouse_id  (greenhouse_id)
#
