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
    grower?
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
