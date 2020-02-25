require 'test_helper'

class Request_distributionTest < ActiveSupport::TestCase
  # Setups
  def setup
    @request_distribution = request_distributions(:request_distribution_1)
  end

  # Validations
  test 'valid request_distribution' do
    assert @request_distribution.valid?, @request_distribution.errors.messages
  end

  test 'valid without pot' do
    @request_distribution.pot = nil
    assert @request_distribution.valid?, @request_distribution.errors.messages
  end

  test 'valid without pot and pot_quantity' do
    @request_distribution.pot = nil
    @request_distribution.pot_quantity = nil
    assert @request_distribution.valid?, @request_distribution.errors.messages
  end

  test 'invalid without pot_quantity if pot is present' do
    assert @request_distribution.pot.present?

    @request_distribution.pot_quantity = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:pot_quantity]
  end

  test 'invalid without request' do
    @request_distribution.request = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:request]
  end

  test 'invalid without bench' do
    @request_distribution.bench = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:bench]
  end

  test 'invalid without plant_stage' do
    @request_distribution.plant_stage = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:plant_stage]
  end

  test 'invalid without area' do
    @request_distribution.area = nil
    assert_not @request_distribution.valid?
    assert_not_empty @request_distribution.errors[:area]
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
