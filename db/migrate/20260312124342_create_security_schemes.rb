class CreateSecuritySchemes < ActiveRecord::Migration[8.1]
  def change
    create_table :security_schemes, id: :uuid do |t|
      t.references :api_revision, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.text :description
      t.jsonb :scheme

      t.timestamps
    end
  end
end
