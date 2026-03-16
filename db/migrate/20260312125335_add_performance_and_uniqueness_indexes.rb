class AddPerformanceAndUniquenessIndexes < ActiveRecord::Migration[8.1]
  def change
    # Unique slugs for clean URLs
    add_index :organizations, :slug, unique: true
    add_index :workspaces, [:organization_id, :slug], unique: true
    add_index :teams, [:workspace_id, :slug], unique: true
    add_index :projects, [:workspace_id, :slug], unique: true

    # Prevent duplicate memberships
    add_index :organization_memberships, [:organization_id, :user_id], unique: true
    add_index :workspace_memberships, [:workspace_id, :user_id], unique: true
    add_index :team_memberships, [:team_id, :user_id], unique: true
    add_index :project_team_accesses, [:project_id, :team_id], unique: true

    add_index :invitations, :token, unique: true

    # Soft-delete optimization
    add_index :organizations, :deleted_at
    add_index :workspaces, :deleted_at
    add_index :projects, :deleted_at
    add_index :api_revisions, :deleted_at

    # Polymorphic comments
    add_index :comments, [:commentable_type, :commentable_id]

    # JSONB GIN indexes (OpenAPI search super-power)
    add_index :api_revisions, :content, using: :gin
    add_index :endpoints, :security, using: :gin
    add_index :parameters, :schema, using: :gin
    add_index :responses, :content, using: :gin
    add_index :schemas, :schema, using: :gin
    add_index :security_schemes, :scheme, using: :gin
    add_index :activity_logs, :metadata, using: :gin

    # Fast revision queries
    add_index :api_revisions, [:api_specification_id, :revision_number]
    add_index :api_revisions, [:api_specification_id, :is_published]
  end
end
