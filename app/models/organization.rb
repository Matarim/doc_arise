# frozen_string_literal: true

class Organization < ApplicationRecord
  include SoftDeletable
  include Sluggable

  has_many :workspaces, dependent: :destroy
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships
  has_many :invitations, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  belongs_to :created_by, class_name: 'User'

  validates :slug, uniqueness: { scope: :deleted_at }
  after_save :update_slug

  def update_slug
    self.slug = name.parameterize
  end

  def slug_uniqueness_scope
    [:deleted_at]
  end
end
