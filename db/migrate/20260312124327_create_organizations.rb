class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :logo_url
      t.string :plan
      t.string :billing_email
      t.string :stripe_customer_id
      t.references :created_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
