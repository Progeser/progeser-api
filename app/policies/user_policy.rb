# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
