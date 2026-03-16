class CreateParameters < ActiveRecord::Migration[8.1]
  def change
    create_table :parameters, id: :uuid do |t|
      t.references :endpoint, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :in_location
      t.boolean :required
      t.text :description
      t.jsonb :schema
      t.jsonb :example

      t.timestamps
    end
  end
end
