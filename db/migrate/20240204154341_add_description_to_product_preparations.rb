class AddDescriptionToProductPreparations < ActiveRecord::Migration[7.0]
  def change
    add_column :product_preparations, :description, :string, after: :id
  end
end
