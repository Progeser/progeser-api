# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def create?
    grower?
  end

  def retry?
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
