class CreateTripFinancialSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_financial_summaries do |t|
      t.references :trip, foreign_key: true, null: false, index: { unique: true }
      t.integer :total_revenue,   null: false
      t.integer :total_expenses,  null: false
      t.integer :total_deficit,   null: false
      t.integer :fair_share,      null: false
      t.integer :committee_count, null: false
      t.timestamps
    end
  end
end
