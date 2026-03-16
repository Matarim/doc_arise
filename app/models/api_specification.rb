# frozen_string_literal: true

class ApiSpecification < ApplicationRecord
  include SoftDeletable

  belongs_to :project
  belongs_to :created_by, class_name: 'User'

  has_many :api_revisions, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :name, presence: true
  validates :default, uniqueness: { scope: :project_id }, if: :default?
end
