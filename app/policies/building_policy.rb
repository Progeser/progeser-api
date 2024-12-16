# frozen_string_literal: true

class BuildingPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    return true if record.greenhouses.flat_map(&:benches).flat_map(&:request_distributions).empty?

    record.errors.add(:request_distributions, 'can\'t delete a building with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
