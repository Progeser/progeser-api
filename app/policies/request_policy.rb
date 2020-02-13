# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
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
    grower?
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.where(author: user)
    end
  end
end
