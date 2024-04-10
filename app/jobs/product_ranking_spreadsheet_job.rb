class ProductRankingSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(year)
    product_sales = ProductSale.where(year_refference: year)
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

    header.each.with_index(0) { |data, row| tab.add_cell(0, row, data) }

    product_sales.each.with_index(1) do |product_sale, col|
      tab.add_cell(col, 0, product_sale.product.item_name)
      tab.add_cell(col, 1, product_sale.product.seller_sku)
      tab.add_cell(col, 2, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'January')&.unit_count)
      tab.add_cell(col, 3, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'February')&.unit_count)
      tab.add_cell(col, 4, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'March')&.unit_count)
      tab.add_cell(col, 5, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'April')&.unit_count)
      tab.add_cell(col, 6, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'May')&.unit_count)
      tab.add_cell(col, 7, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'June')&.unit_count)
      tab.add_cell(col, 8, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'July')&.unit_count)
      tab.add_cell(col, 9, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'August')&.unit_count)
      tab.add_cell(col, 10, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'September')&.unit_count)
      tab.add_cell(col, 11, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'October')&.unit_count)
      tab.add_cell(col, 12, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'November')&.unit_count)
      tab.add_cell(col, 13, ProductSale.find_by(product_id: product_sale.product_id, month_refference: 'December')&.unit_count)
    end

    workbook.stream.read
  end
end
