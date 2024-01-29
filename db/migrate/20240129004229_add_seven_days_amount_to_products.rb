class AddSevenDaysAmountToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :total_unit_count_7, :string, after: :total_sales_amount
    add_column :products, :total_sales_amount_7, :string, after: :total_unit_count_7
  end
end
