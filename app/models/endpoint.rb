# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :api_revision

  has_many :parameters, dependent: :destroy
  has_many :responses, dependent: :destroy

  validates :version, presence: true

  # File #1: independent versioning helpers
  def self.default_version
    '1.0.0'
  end

  def increment_version!
    return unless version.present?

    major, minor, patch = version.split('.').map(&:to_i)
    self.version = "#{major}.#{minor}.#{patch + 1}"
    save!
  end

  def independent_version?
    version != api_revision.version
  end

  def to_openapi_extension
    { 'x-docarise-endpoint-version' => version }
  end

  def self.from_openapi_extension(operation_hash)
    version = operation_hash.dig('x-docarise-endpoint-version') || Endpoint.default_version
    new(version: version)
  end
end
