class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "user"
      t.string :status, null: false, default: "active"
      t.text   :password_reset_token
      t.datetime :password_reset_sent_at
      t.text   :email_verification_token
      t.datetime :email_verification_sent_at
      t.datetime :email_verification_accepted_at
      t.boolean :email_verification_accepted
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :email_address, unique: true
    add_index :users, :status
    add_index :users, :email_verification_token, unique: true
    add_index :users, :password_reset_token, unique: true
  end
end
