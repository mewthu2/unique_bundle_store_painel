class ProductRankingSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(year, kind)
    if kind == 'thirty_days'
      generate_thirty_days_data(year)
    elsif kind == 'seven_days'
      generate_seven_days_data(year)
    else
      raise ArgumentError, "Invalid 'kind' parameter. Please specify either 'thirty_days' or 'seven_days'."
    end
  end

  private

  def generate_thirty_days_data(year)
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

  def generate_seven_days_data(year)
    product_sales = ProductSale.includes(:product)
                               .where(year_refference: year, kind: 'seven_days')
                               .group_by { |sale| sale&.product_id }

    workbook = RubyXL::Workbook.new
    tab = workbook.worksheets[0]
    tab.sheet_name = 'Product Sales Spreadsheet'

    header = ['Product Name', 'SKU', 'Fulfillment Channel', 'ASIN1']

    months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    weeks = (1..5).map { |week| "Week #{week}" }

    months.each do |month|
      weeks.each do |week|
        header << "#{month} #{week}"
      end
    end

    header.each_with_index { |data, col| tab.add_cell(0, col, data) }

    row_index = 1

    product_sales.each_value do |sales|
      product = sales.first.product

      monthly_sales = Hash.new { |h, k| h[k] = Hash.new(0) }

      sales.each do |sale|
        month_week = "#{sale.month_refference} #{weeks[sale.week_refference.to_i - 1]}"
        monthly_sales[sale.month_refference][month_week] += sale.unit_count.to_i
      end

      tab.add_cell(row_index, 0, product.item_name)
      tab.add_cell(row_index, 1, product.seller_sku)
      tab.add_cell(row_index, 2, product.fulfillment_channel)
      tab.add_cell(row_index, 3, product.asin1)

      months.each_with_index do |month, month_index|
        weeks.each_with_index do |week, week_index|
          month_week = "#{month} #{week}"
          tab.add_cell(row_index, 4 + (month_index * weeks.length) + week_index, monthly_sales[month][month_week])
        end
      end

      row_index += 1
    end

    workbook.stream.read
  end
end
