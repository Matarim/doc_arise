class CreateWorkspaceMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :workspace_memberships, id: :uuid do |t|
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role

      t.timestamps
    end
  end
end
