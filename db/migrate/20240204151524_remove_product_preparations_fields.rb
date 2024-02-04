class RemoveProductPreparationsFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :product_preparations, :quantity, type: :string
    remove_column :product_preparations, :product_id, type: :bigint
    remove_column :product_preparations, :kind, type: :bigint
  end
end
