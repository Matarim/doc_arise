class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.references :team, null: true, foreign_key: true, type: :uuid
      t.string :visibility
      t.string :icon
      t.string :color
      t.jsonb :settings
      t.references :created_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
