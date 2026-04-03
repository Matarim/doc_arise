# frozen_string_literal: true

class ApiRevision < ApplicationRecord
  include SoftDeletable

  belongs_to :api_specification
  belongs_to :committed_by, class_name: 'User'
  belongs_to :parent_revision, class_name: 'ApiRevision', optional: true

  has_many :endpoints, dependent: :destroy
  has_many :schemas, dependent: :destroy
  has_many :security_schemes, dependent: :destroy

  validates :version,         presence: true
  validates :branch,          presence: true
  validates :revision_number, presence: true, uniqueness: { scope: %i[api_specification_id branch] }

  scope :for_branch, ->(branch) { where(branch: branch) }
  scope :main, -> { for_branch('main') }

  scope :published, -> { where(is_published: true) }
  scope :latest,    -> { order(revision_number: :desc).first }

  def self.default_branch
    'main'
  end
end
