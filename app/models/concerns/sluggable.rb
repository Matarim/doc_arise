# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, on: :create

    validates :slug,
              presence: true,
              format:   { with: /\A[a-z0-9-]+\z/ }
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end
end
