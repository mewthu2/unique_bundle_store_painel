class AddPendingCustomerOrderQuantityToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :pending_customer_order_quantity, :string, after: :resolver_stock
  end
end
