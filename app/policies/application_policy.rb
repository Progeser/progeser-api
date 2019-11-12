# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  delegate :requester?, :grower?, to: :user

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

    delegate :requester?, :grower?, to: :user

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
