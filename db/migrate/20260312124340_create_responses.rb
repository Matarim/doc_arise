class CreateResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :responses, id: :uuid do |t|
      t.references :endpoint, null: false, foreign_key: true, type: :uuid
      t.string :status_code
      t.text :description
      t.jsonb :content

      t.timestamps
    end
  end
end
