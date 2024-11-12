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
    assert_includes @bench.errors[:dimensions], "doit être rempli(e)"
  end

  test 'invalid with wrong number of dimensions' do
    @bench.dimensions = [10]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'should contain exactly two elements: length and width'

    @bench.dimensions = [10, 20, 30]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'should contain exactly two elements: length and width'
  end

  test 'invalid with non-positive dimensions' do
    @bench.dimensions = [10, -20]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'each dimension must be greater than 0'

    @bench.dimensions = [0, 30]
    assert_not @bench.valid?
    assert_includes @bench.errors[:dimensions], 'each dimension must be greater than 0'
  end

  test 'invalid without position' do
    @bench.positions = nil
    assert_not @bench.valid?
    assert_includes @bench.errors[:positions], "doit être rempli(e)"
  end

  test 'invalid with negative position' do
    @bench.positions = [10, -20]
    assert_not @bench.valid?
    assert_includes @bench.errors[:positions], 'each position must be positive'

    @bench.positions = [-1, 0]
    assert_not @bench.valid?
    assert_includes @bench.errors[:positions], 'each position must be positive'
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
