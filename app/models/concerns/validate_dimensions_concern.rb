# frozen_string_literal: true

require 'active_support/concern'

module ValidateDimensionsConcern
  extend ActiveSupport::Concern

  included do
    validates :dimensions,
              presence: true,
              length: { is: 2,
                        message: I18n.t('activerecord.errors.concern.attributes.dimensions.incorrect_size') }
    validate :dimensions_must_be_strictly_positive

    private

    def dimensions_must_be_strictly_positive
      return unless dimensions

      return unless dimensions.any? { |d| d <= 0 }

      errors.add(:dimensions, I18n.t('activerecord.errors.concern.attributes.dimensions.not_positive'))
    end
  end
end
