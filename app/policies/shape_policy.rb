# frozen_string_literal: true

class ShapePolicy < ApplicationPolicy
  def index?
    grower?
  end
end
