# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace, optional: true
  belongs_to :user
end
