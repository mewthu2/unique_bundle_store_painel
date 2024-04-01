class CreateProductSales< ActiveRecord::Migration[7.0]
  def change
    create_table :product_sales do |t|
      t.references :product, null: false, foreign_key: true, index: true
      t.bigint :kind
      t.string :month_refference
      t.string :week_refference
      t.string :year_refference
      t.string :interval
      t.string :unit_count
      t.string :order_item_count
      t.string :order_count
      t.string :average_unit_price
      t.string :average_unit_price_currency
      t.string :total_sales
      t.string :total_sales_currency
      t.timestamps
    end
  end
end
