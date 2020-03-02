# frozen_string_literal: true

class PlantPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    grower?
  end

  def update?
    grower?
  end

  def destroy?
    return false unless grower?

    return true if record.plant_stages.flat_map(&:request_distributions).empty?

    record.errors.add(:request_distributions, 'can\'t delete a plant with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
