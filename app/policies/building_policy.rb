# frozen_string_literal: true

class BuildingPolicy < ApplicationPolicy
  def index?
    grower?
  end

  def show?
    grower?
  end

  def create?
    grower?
  end

  def update?
    grower?
  end

  def destroy?
    return false unless grower?

    return true if record.greenhouses.flat_map(&:benches).flat_map(&:distributions).empty?

    record.errors.add(:distributions, 'can\'t delete a building with ongoing requests')
    false
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
