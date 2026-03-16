class CreateTeamMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :team_memberships, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role

      t.timestamps
    end
  end
end
