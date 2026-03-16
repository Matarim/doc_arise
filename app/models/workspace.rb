# frozen_string_literal: true

class Workspace < ApplicationRecord
  include SoftDeletable
  include Sluggable

  belongs_to :organization
  belongs_to :created_by, class_name: 'User'

  has_many :teams, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :workspace_memberships, dependent: :destroy
  has_many :users, through: :workspace_memberships
  has_many :invitations, dependent: :destroy

  validates :slug, uniqueness: { scope: :organization_id }
  after_save :update_slug

  def update_slug
    self.slug = name.parameterize
  end

  def slug_uniqueness_scope
    [:organization_id]
  end
end
