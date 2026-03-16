# frozen_string_literal: true

class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[lead member] }
end
