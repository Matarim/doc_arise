class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :action
      t.string :target_type
      t.uuid :target_id
      t.jsonb :metadata
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
