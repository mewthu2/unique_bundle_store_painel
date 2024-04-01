class ProductRankingSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(product_sales)
    workbook = RubyXL::Workbook.new

    tab = workbook.worksheets[0]
    tab.sheet_name = 'Product Sales Spreadsheet'

    header = ['Month Reference',
              'Week Reference',
              'Year Reference',
              'Interval',
              'Unit Count',
              'Order Item Count',
              'Order Count',
              'Average Unit Price',
              'Average Unit Price Currency',
              'Total Sales',
              'Total Sales Currency',
              'Created At',
              'Updated At']

    header.each.with_index(0) { |data, row| tab.add_cell(0, row, data) }

    product_sales.each.with_index(1) do |product_sale, col|
      tab.add_cell(col, 0, product_sale.month_refference)
      tab.add_cell(col, 1, product_sale.week_refference)
      tab.add_cell(col, 2, product_sale.year_refference)
      tab.add_cell(col, 3, product_sale.interval)
      tab.add_cell(col, 4, product_sale.unit_count)
      tab.add_cell(col, 5, product_sale.order_item_count)
      tab.add_cell(col, 6, product_sale.order_count)
      tab.add_cell(col, 7, product_sale.average_unit_price)
      tab.add_cell(col, 8, product_sale.average_unit_price_currency)
      tab.add_cell(col, 9, product_sale.total_sales)
      tab.add_cell(col, 10, product_sale.total_sales_currency)
      tab.add_cell(col, 11, product_sale.created_at.strftime('%d/%m/%Y'))
      tab.add_cell(col, 12, product_sale.updated_at.strftime('%d/%m/%Y'))
    end

    workbook.stream.read
  end
end
