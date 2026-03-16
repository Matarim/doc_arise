class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.string :color
      t.references :created_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
