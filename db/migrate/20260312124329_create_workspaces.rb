class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :icon
      t.jsonb :settings
      t.references :created_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
