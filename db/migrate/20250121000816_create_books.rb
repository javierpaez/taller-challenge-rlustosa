class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.references :author, null: false, foreign_key: true
      t.datetime :publication_date, null: false
      t.integer :rating, default: 0
      t.string :status, default: "available"

      t.timestamps
    end
  end
end
