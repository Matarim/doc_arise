# frozen_string_literal: true

class ProjectTeamAccess < ApplicationRecord
  belongs_to :project
  belongs_to :team

  validates :permission_level, presence: true, inclusion: { in: %w[read write admin] }
end
