# frozen_string_literal: true

class Team < ApplicationRecord
  include SoftDeletable
  include Sluggable

  belongs_to :workspace
  belongs_to :created_by, class_name: 'User'

  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships
  has_many :project_team_accesses, dependent: :destroy

  validates :slug, uniqueness: { scope: :workspace_id }

  def slug_uniqueness_scope
    [:workspace_id]
  end
end
