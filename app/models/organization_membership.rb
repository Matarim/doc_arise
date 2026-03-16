# frozen_string_literal: true

class OrganizationMembership < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :invited_by, class_name: 'User', optional: true

  validates :role, presence: true, inclusion: { in: %w[owner admin member viewer] }
end
