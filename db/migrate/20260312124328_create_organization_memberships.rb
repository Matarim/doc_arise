class CreateOrganizationMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_memberships, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role
      t.datetime :joined_at
      t.references :invited_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
