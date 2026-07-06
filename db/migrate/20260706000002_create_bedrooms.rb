class CreateBedrooms < ActiveRecord::Migration[5.2]
  def change
    create_table :bedrooms do |t|
      t.references :house, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
