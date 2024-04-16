class ProductRankingSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(year)
    product_sales = ProductSale.includes(:product)
                               .where(year_refference: year)
                               .group_by { |sale| sale&.product_id }

    workbook = RubyXL::Workbook.new
    tab = workbook.worksheets[0]
    tab.sheet_name = 'Product Sales Spreadsheet'

    header = ['Product Name',
              'SKU',
              'Fulfillment Channel',
              'ASIN1',
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December']

    header.each_with_index { |data, col| tab.add_cell(0, col, data) }

    row_index = 1

    product_sales.each_value do |sales|
      product = sales.first.product
      tab.add_cell(row_index, 0, product.item_name)
      tab.add_cell(row_index, 1, product.seller_sku)
      tab.add_cell(row_index, 2, product.fulfillment_channel)
      tab.add_cell(row_index, 3, product.asin1)

      month_columns = { 'January' => 4, 'February' => 5, 'March' => 6, 'April' => 7, 'May' => 8, 'June' => 9, 'July' => 10, 'August' => 11, 'September' => 12, 'October' => 13, 'November' => 14, 'December' => 15 }

      sales.each do |sale|
        month_index = month_columns[sale.month_refference]
        tab.add_cell(row_index, month_index, sale.unit_count)
      end

      row_index += 1
    end

    workbook.stream.read
  end
end
