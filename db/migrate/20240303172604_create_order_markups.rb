class CreateOrderMarkups < ActiveRecord::Migration[7.0]
  def change
    create_table :order_markups do |t|
      t.bigint :status
      t.string :amazon_order_id
      t.timestamps
    end
  end
end
