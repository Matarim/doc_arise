class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags, id: :uuid do |t|
      t.references :api_specification, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
