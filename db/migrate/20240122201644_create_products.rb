class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :item_name
      t.longtext :item_description
      t.string :listing_id
      t.string :seller_sku
      t.string :price
      t.string :quantity
      t.string :product_id_type
      t.string :asin1
      t.string :asin2
      t.string :asin3
      t.string :id_product
      t.string :status
      t.string :fulfillment_channel
      t.string :total_unit_count
      t.string :total_sales_amount
      t.string :resolver_stock
      t.timestamps
    end
  end
end
