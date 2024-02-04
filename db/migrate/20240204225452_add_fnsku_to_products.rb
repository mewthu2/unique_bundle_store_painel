class AddFnskuToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :fnsku, :string, after: :seller_sku
  end
end
