# frozen_string_literal: true

class Project < ApplicationRecord
  include SoftDeletable
  include Sluggable

  belongs_to :workspace
  belongs_to :team, optional: true
  belongs_to :created_by, class_name: 'User'

  has_many :api_specifications, dependent: :destroy
  has_many :project_team_accesses, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :teams_with_access, through: :project_team_accesses, source: :team

  validates :slug, uniqueness: { scope: :workspace_id }
  after_save :update_slug

  def update_slug
    self.slug = name.parameterize
  end

  def slug_uniqueness_scope
    [:workspace_id]
  end
end
