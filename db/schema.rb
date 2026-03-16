# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_12_125335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.jsonb "metadata"
    t.uuid "organization_id", null: false
    t.uuid "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.uuid "workspace_id", null: false
    t.index ["metadata"], name: "index_activity_logs_on_metadata", using: :gin
    t.index ["organization_id"], name: "index_activity_logs_on_organization_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
    t.index ["workspace_id"], name: "index_activity_logs_on_workspace_id"
  end

  create_table "api_revisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_specification_id", null: false
    t.text "commit_message"
    t.uuid "committed_by_id"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.boolean "is_draft"
    t.boolean "is_published"
    t.uuid "parent_revision_id"
    t.datetime "published_at"
    t.integer "revision_number"
    t.datetime "updated_at", null: false
    t.text "yaml_content"
    t.index ["api_specification_id", "is_published"], name: "index_api_revisions_on_api_specification_id_and_is_published"
    t.index ["api_specification_id", "revision_number"], name: "idx_on_api_specification_id_revision_number_e62c6f513d"
    t.index ["api_specification_id"], name: "index_api_revisions_on_api_specification_id"
    t.index ["committed_by_id"], name: "index_api_revisions_on_committed_by_id"
    t.index ["content"], name: "index_api_revisions_on_content", using: :gin
    t.index ["deleted_at"], name: "index_api_revisions_on_deleted_at"
    t.index ["parent_revision_id"], name: "index_api_revisions_on_parent_revision_id"
  end

  create_table "api_specifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.boolean "default"
    t.datetime "deleted_at"
    t.text "description"
    t.string "name"
    t.uuid "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_api_specifications_on_created_by_id"
    t.index ["project_id"], name: "index_api_specifications_on_project_id"
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "commentable_id"
    t.string "commentable_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.uuid "parent_comment_id"
    t.boolean "resolved"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["parent_comment_id"], name: "index_comments_on_parent_comment_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "endpoints", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_revision_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deprecated"
    t.text "description"
    t.string "method"
    t.string "operation_id"
    t.string "path"
    t.jsonb "security"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["api_revision_id"], name: "index_endpoints_on_api_revision_id"
    t.index ["security"], name: "index_endpoints_on_security", using: :gin
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.uuid "inviter_id"
    t.uuid "organization_id"
    t.string "role"
    t.string "status"
    t.uuid "team_id"
    t.string "token"
    t.datetime "updated_at", null: false
    t.uuid "workspace_id"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["team_id"], name: "index_invitations_on_team_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
    t.index ["workspace_id"], name: "index_invitations_on_workspace_id"
  end

  create_table "organization_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invited_by_id"
    t.datetime "joined_at"
    t.uuid "organization_id", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["invited_by_id"], name: "index_organization_memberships_on_invited_by_id"
    t.index ["organization_id", "user_id"], name: "index_organization_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["user_id"], name: "index_organization_memberships_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "billing_email"
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.datetime "deleted_at"
    t.text "description"
    t.string "logo_url"
    t.string "name"
    t.string "plan"
    t.string "slug"
    t.string "stripe_customer_id"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_organizations_on_created_by_id"
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "parameters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.uuid "endpoint_id", null: false
    t.jsonb "example"
    t.string "in_location"
    t.string "name"
    t.boolean "required"
    t.jsonb "schema"
    t.datetime "updated_at", null: false
    t.index ["endpoint_id"], name: "index_parameters_on_endpoint_id"
    t.index ["schema"], name: "index_parameters_on_schema", using: :gin
  end

  create_table "project_team_accesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "permission_level"
    t.uuid "project_id", null: false
    t.uuid "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "team_id"], name: "index_project_team_accesses_on_project_id_and_team_id", unique: true
    t.index ["project_id"], name: "index_project_team_accesses_on_project_id"
    t.index ["team_id"], name: "index_project_team_accesses_on_team_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.datetime "deleted_at"
    t.text "description"
    t.string "icon"
    t.string "name"
    t.jsonb "settings"
    t.string "slug"
    t.uuid "team_id"
    t.datetime "updated_at", null: false
    t.string "visibility"
    t.uuid "workspace_id", null: false
    t.index ["created_by_id"], name: "index_projects_on_created_by_id"
    t.index ["deleted_at"], name: "index_projects_on_deleted_at"
    t.index ["team_id"], name: "index_projects_on_team_id"
    t.index ["workspace_id", "slug"], name: "index_projects_on_workspace_id_and_slug", unique: true
    t.index ["workspace_id"], name: "index_projects_on_workspace_id"
  end

  create_table "responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.text "description"
    t.uuid "endpoint_id", null: false
    t.string "status_code"
    t.datetime "updated_at", null: false
    t.index ["content"], name: "index_responses_on_content", using: :gin
    t.index ["endpoint_id"], name: "index_responses_on_endpoint_id"
  end

  create_table "schemas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_revision_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.jsonb "schema"
    t.datetime "updated_at", null: false
    t.index ["api_revision_id"], name: "index_schemas_on_api_revision_id"
    t.index ["schema"], name: "index_schemas_on_schema", using: :gin
  end

  create_table "security_schemes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_revision_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.jsonb "scheme"
    t.datetime "updated_at", null: false
    t.index ["api_revision_id"], name: "index_security_schemes_on_api_revision_id"
    t.index ["scheme"], name: "index_security_schemes_on_scheme", using: :gin
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "api_specification_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["api_specification_id"], name: "index_tags_on_api_specification_id"
  end

  create_table "team_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role"
    t.uuid "team_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
    t.index ["user_id"], name: "index_team_memberships_on_user_id"
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.datetime "deleted_at"
    t.text "description"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.uuid "workspace_id", null: false
    t.index ["created_by_id"], name: "index_teams_on_created_by_id"
    t.index ["workspace_id", "slug"], name: "index_teams_on_workspace_id_and_slug", unique: true
    t.index ["workspace_id"], name: "index_teams_on_workspace_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email_address", null: false
    t.boolean "email_verification_accepted"
    t.datetime "email_verification_accepted_at"
    t.datetime "email_verification_sent_at"
    t.text "email_verification_token"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.text "password_reset_token"
    t.string "role", default: "user", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["email_verification_token"], name: "index_users_on_email_verification_token", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
    t.index ["status"], name: "index_users_on_status"
  end

  create_table "workspace_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "workspace_id", null: false
    t.index ["user_id"], name: "index_workspace_memberships_on_user_id"
    t.index ["workspace_id", "user_id"], name: "index_workspace_memberships_on_workspace_id_and_user_id", unique: true
    t.index ["workspace_id"], name: "index_workspace_memberships_on_workspace_id"
  end

  create_table "workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.datetime "deleted_at"
    t.text "description"
    t.string "icon"
    t.string "name"
    t.uuid "organization_id", null: false
    t.jsonb "settings"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_workspaces_on_created_by_id"
    t.index ["deleted_at"], name: "index_workspaces_on_deleted_at"
    t.index ["organization_id", "slug"], name: "index_workspaces_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_workspaces_on_organization_id"
  end

  add_foreign_key "activity_logs", "organizations"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "activity_logs", "workspaces"
  add_foreign_key "api_revisions", "api_revisions", column: "parent_revision_id"
  add_foreign_key "api_revisions", "api_specifications"
  add_foreign_key "api_revisions", "users", column: "committed_by_id"
  add_foreign_key "api_specifications", "projects"
  add_foreign_key "api_specifications", "users", column: "created_by_id"
  add_foreign_key "comments", "comments", column: "parent_comment_id"
  add_foreign_key "comments", "users"
  add_foreign_key "endpoints", "api_revisions"
  add_foreign_key "identities", "users"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "teams"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "invitations", "workspaces"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "organization_memberships", "users", column: "invited_by_id"
  add_foreign_key "organizations", "users", column: "created_by_id"
  add_foreign_key "parameters", "endpoints"
  add_foreign_key "project_team_accesses", "projects"
  add_foreign_key "project_team_accesses", "teams"
  add_foreign_key "projects", "teams"
  add_foreign_key "projects", "users", column: "created_by_id"
  add_foreign_key "projects", "workspaces"
  add_foreign_key "responses", "endpoints"
  add_foreign_key "schemas", "api_revisions"
  add_foreign_key "security_schemes", "api_revisions"
  add_foreign_key "sessions", "users"
  add_foreign_key "tags", "api_specifications"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "teams", "users", column: "created_by_id"
  add_foreign_key "teams", "workspaces"
  add_foreign_key "workspace_memberships", "users"
  add_foreign_key "workspace_memberships", "workspaces"
  add_foreign_key "workspaces", "organizations"
  add_foreign_key "workspaces", "users", column: "created_by_id"
end
