class CreateBeds < ActiveRecord::Migration[5.2]
  def change
    create_table :beds do |t|
      t.references :bedroom, null: false, foreign_key: true
      t.string  :description
      t.integer :capacity, null: false, default: 1
      t.integer :rank, null: false
      t.timestamps
    end
  end
end
