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

    header.each_with_index { |data, row| tab.add_cell(0, row, data) }

    row_index = 1

    product_sales.each_value do |sales|
      product = sales.first.product
      tab.add_cell(row_index, 0, product.item_name)
      tab.add_cell(row_index, 1, product.seller_sku)

      sales.each do |sale|
        month_index = Date::MONTHNAMES.index(sale.month_refference)
        tab.add_cell(row_index, month_index, sale.unit_count)
      end

      row_index += 1
    end

    workbook.stream.read
  end
end
