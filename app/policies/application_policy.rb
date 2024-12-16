# frozen_string_literal: true

# This class contains empty methods to force redefining them whenever they are required
#
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?; end

  def show?; end

  def create?; end

  def update?; end

  def destroy?; end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve; end
  end
end
