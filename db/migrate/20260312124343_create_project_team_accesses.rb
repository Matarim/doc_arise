class CreateProjectTeamAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :project_team_accesses, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.string :permission_level

      t.timestamps
    end
  end
end
