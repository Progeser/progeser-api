# frozen_string_literal: true

class AccountRequestPolicy < ApplicationPolicy
  def index?
    grower?
  end

  def show?
    grower?
  end

  def accept?
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
