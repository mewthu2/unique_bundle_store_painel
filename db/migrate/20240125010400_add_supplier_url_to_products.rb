class AddSupplierUrlToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :supplier_url, :string, after: :resolver_stock
  end
end
