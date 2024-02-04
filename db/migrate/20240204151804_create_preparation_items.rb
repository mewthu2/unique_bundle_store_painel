class CreatePreparationItems < ActiveRecord::Migration[7.0]
  def change
    create_table :preparation_items do |t|
      t.references :product_preparation, null: false, foreign_key: true, index: true
      t.references :product, null: false, foreign_key: true, index: true
      t.integer :quantity
      t.bigint :kind
      t.timestamps
    end
  end
end
