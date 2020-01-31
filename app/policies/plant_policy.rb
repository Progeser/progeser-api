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
    grower?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
