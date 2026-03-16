class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations, id: :uuid do |t|
      t.string :email
      t.string :token
      t.string :role
      t.datetime :expires_at
      t.string :status
      t.references :organization, null: true, foreign_key: true, type: :uuid
      t.references :workspace, null: true, foreign_key: true, type: :uuid
      t.references :team, null: true, foreign_key: true, type: :uuid
      t.references :inviter, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
