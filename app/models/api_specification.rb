# frozen_string_literal: true

class ApiSpecification < ApplicationRecord
  include SoftDeletable

  belongs_to :project
  belongs_to :created_by, class_name: 'User'

  has_many :api_revisions, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :name, presence: true
  validates :default, uniqueness: { scope: :project_id }, if: :default?
  validates :openapi_version, inclusion: { in: %w[3.0.0 3.0.1 3.1.0] }, allow_nil: true

  def latest_published_revision
    api_revisions.where(is_published: true, deleted_at: nil)
                 .order(revision_number: :desc)
                 .first
  end

  def ensure_draft_revision!(user)
    candidate_draft = api_revisions.where(deleted_at: nil)
                                   .where(is_published: [false, nil])
                                   .order(revision_number: :desc)
                                   .first

    if candidate_draft
      content = candidate_draft.content
      content = JSON.parse(content) if content.is_a?(String)

      if content.is_a?(Hash) && content.dig('paths')&.any?
        return candidate_draft
      end
    end

    parent = api_revisions.where(is_published: true, deleted_at: nil)
                          .order(revision_number: :desc)
                          .first

    next_number = (api_revisions.maximum(:revision_number) || 0) + 1
    next_version = if parent&.version
                     parent.version.sub(/\d+$/) { |n| (n.to_i + 1).to_s }
                   else
                     '1.0.0'
                   end

    forked_content = if parent&.content.present?
                       parent.content.is_a?(String) ? JSON.parse(parent.content) : parent.content.deep_dup
                     else
                       {
                         openapi: '3.1.0',
                         info:    { title: name, version: next_version },
                         paths:   {}
                       }
                     end

    api_revisions.create!(
      revision_number:    next_number,
      version:            next_version,
      commit_message:     parent.present? ? "Draft of v#{next_version} (from published ##{parent.revision_number})" : 'Initial draft',
      parent_revision_id: parent&.id,
      committed_by:       user,
      is_published:       false,
      is_draft:           true,
      content:            forked_content
    )
  end
end
