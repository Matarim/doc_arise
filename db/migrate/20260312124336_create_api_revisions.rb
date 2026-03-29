class CreateApiRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :api_revisions, id: :uuid do |t|
      t.references :api_specification, null: false, foreign_key: true, type: :uuid
      t.integer :revision_number
      t.string :version, null: false, default: "1.0.0"
      t.jsonb :content
      t.text :yaml_content
      t.text :commit_message
      t.references :committed_by, type: :uuid, foreign_key: { to_table: :users }
      t.boolean :is_draft
      t.boolean :is_published
      t.datetime :published_at
      t.references :parent_revision, type: :uuid, foreign_key: { to_table: :api_revisions }
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
