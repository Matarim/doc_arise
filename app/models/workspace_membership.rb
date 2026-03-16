# frozen_string_literal: true

class WorkspaceMembership < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[admin member viewer] }
end
