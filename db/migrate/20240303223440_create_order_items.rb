class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :product, null: false, foreign_key: true, index: true
      t.string :amazon_order_id
      t.string :quantity
      t.timestamps
    end
  end
end
