# frozen_string_literal: true

class PotPolicy < ApplicationPolicy
  def create?
    grower?
  end

  class Scope < Scope
    def resolve
      grower? ? scope.all : scope.none
    end
  end
end
