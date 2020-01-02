require 'test_helper'

class BenchTest < ActiveSupport::TestCase
  # Setups
  def setup
    @bench = benches(:bench_1)
  end

  # Validations
  test 'valid bench' do
    assert @bench.valid?, @bench.errors.messages
  end

  test 'valid without name' do
    @bench.name = nil
    assert @bench.valid?, @bench.errors.messages
  end

  test 'invalid without shape' do
    @bench.shape = nil
    assert_not @bench.valid?
    assert_not_empty @bench.errors[:shape]
  end

  test 'invalid without area' do
    @bench.area = nil
    assert_not @bench.valid?
    assert_not_empty @bench.errors[:area]
   end

  test 'invalid with incorrect area value' do
    @bench.area = 0
    assert_not @bench.valid?
    assert_not_empty @bench.errors[:area]
  end

  # Enumerize
  test 'invalid with incorrect shape value' do
    @bench.shape = 'foo'
    assert_not @bench.valid?
    assert_not_empty @bench.errors[:shape]
  end
end

# == Schema Information
#
# Table name: benches
#
#  id            :bigint           not null, primary key
#  greenhouse_id :bigint
#  name          :string
#  shape         :string           not null
#  area          :decimal(, )      not null
#  dimensions    :integer          is an Array
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_benches_on_greenhouse_id  (greenhouse_id)
#
