class AddKindToProductPreparations < ActiveRecord::Migration[7.0]
  def change
    add_column :product_preparations, :kind, :bigint, after: :id
  end
end
