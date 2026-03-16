# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :workspace,    optional: true
  belongs_to :team,         optional: true
  belongs_to :inviter, class_name: 'User'

  validates :email, presence: true, uniqueness: { scope: %i[organization_id workspace_id team_id] }
  validates :status, inclusion: { in: %w[pending accepted expired] }

  # Ensure exactly one scope is set (organization OR workspace OR team)
  validate :exactly_one_scope

  private

  def exactly_one_scope
    scopes = [organization_id, workspace_id, team_id].compact
    errors.add(:base, 'Must belong to exactly one of organization, workspace, or team') if scopes.size != 1
  end
end
