class CreateEndpoints < ActiveRecord::Migration[8.1]
  def change
    create_table :endpoints, id: :uuid do |t|
      t.references :api_revision, null: false, foreign_key: true, type: :uuid
      t.string :path
      t.string :method
      t.string :operation_id
      t.text :summary
      t.text :description
      t.boolean :deprecated
      t.jsonb :security

      t.timestamps
    end
  end
end
