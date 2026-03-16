class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.uuid :commentable_id
      t.string :commentable_type
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :content
      t.references :parent_comment, type: :uuid, foreign_key: { to_table: :comments }
      t.boolean :resolved

      t.timestamps
    end
  end
end
