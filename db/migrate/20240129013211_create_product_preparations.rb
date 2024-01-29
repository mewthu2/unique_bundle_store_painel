class CreateProductPreparations < ActiveRecord::Migration[7.0]
  def change
    create_table :product_preparations do |t|
      t.references :product, null: false, foreign_key: true, index: true
      t.string :quantity
      t.timestamps
    end
  end
end
