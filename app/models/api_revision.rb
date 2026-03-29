# frozen_string_literal: true

class ApiRevision < ApplicationRecord
  include SoftDeletable

  belongs_to :api_specification
  belongs_to :committed_by, class_name: 'User'
  belongs_to :parent_revision, class_name: 'ApiRevision', optional: true

  has_many :endpoints, dependent: :destroy
  has_many :schemas, dependent: :destroy
  has_many :security_schemes, dependent: :destroy

  validates :revision_number, presence: true, uniqueness: { scope: :api_specification_id }
  validates :version,         presence: true

  scope :published, -> { where(is_published: true) }
  scope :latest,    -> { order(revision_number: :desc).first }
end
