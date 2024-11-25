class UpdateProductSalesJob < ActiveJob::Base
  queue_as :default

  def perform(kind, month)
    @access_token = obtain_acess_token

    update_product_sales_info(kind, month)
  end

  def update_product_sales_info(kind, month)
    case kind
    when 'thirty_days'
      update_thirty_days_sales(month)
    when 'seven_days'
      update_seven_days_sales(month)
    end
  end

  def update_thirty_days_sales(month)
    products = Product.where(status: 'Active')

    data_reference = month.present? ? Date.new(Date.today.year, month, 1) : Date.today.prev_month

    start_date = data_reference.beginning_of_month.strftime('%Y-%m-%dT00:00:00Z')
    end_date = data_reference.end_of_month.strftime('%Y-%m-%dT%H:%M:%SZ')
    date_range = "#{start_date}--#{end_date}"

    products.each do |prd|
      next if ProductSale.where(product_id: prd.id, month_refference: data_reference.strftime('%B'), year_refference: Date.today.year, kind: 'thirty_days').present?

      p('Sleeping for 1 second...')
      sleep(1.seconds)

      request_params = {
        granularity: 'total',
        interval: date_range,
        marketplaceIds: ENV['MARKETPLACE_ID'],
        sku: prd.seller_sku
      }

      endpoint = 'https://sellingpartnerapi-na.amazon.com/sales/v1/orderMetrics'

      response = HTTParty.get(endpoint, query: request_params,
                                        headers: { 'x-amz-access-token' => @access_token })
      data = response['payload']&.first

      next unless response['payload'].present?

      update_or_create_product_sale(prd, nil, date_range, data, 'thirty_days', data_reference)
    end
  end

  def update_seven_days_sales(month = nil)
    products = Product.where(status: 'Active')

    month_start = Date.new(Date.today.year, month.present? ? month : Date.today.month, 1)
    weeks_in_month = (month_start..month_start.end_of_month).each_slice(7)

    week_number = 1

    weeks_in_month.each do |week|
      start_date = week.first.strftime('%Y-%m-%dT00:00:00Z')
      end_date = week.last.strftime('%Y-%m-%dT%H:%M:%SZ')
      date_range = "#{start_date}--#{end_date}"

      products.each do |prd|
        product_sale = ProductSale.where(product_id: prd.id,
                                         week_refference: week_number,
                                         kind: 'seven_days',
                                         interval: date_range,
                                         month_refference: month_start.strftime('%B'),
                                         year_refference: Date.today.year)
        next if product_sale.present?

        p('Sleeping for 1 second...')
        sleep(1.seconds)

        request_params = {
          granularity: 'total',
          interval: date_range,
          marketplaceIds: ENV['MARKETPLACE_ID'],
          sku: prd.seller_sku
        }

        endpoint = 'https://sellingpartnerapi-na.amazon.com/sales/v1/orderMetrics'

        response = HTTParty.get(endpoint, query: request_params,
                                          headers: { 'x-amz-access-token' => @access_token })
        data = response['payload']&.first

        next unless response['payload'].present?
        update_or_create_product_sale(prd, week_number, date_range, data, 'seven_days', month_start)
      end
      week_number += 1
    end
  end

  private

  def update_or_create_product_sale(prd, week_of_month, date_range, data, kind, data_reference)
    product_sale = ProductSale.find_by(product_id: prd.id,
                                       kind:,
                                       month_refference: data_reference.strftime('%B'),
                                       week_refference: week_of_month,
                                       year_refference: Date.today.year,
                                       interval: date_range)

    if product_sale
      product_sale.update(unit_count: data['unitCount'],
                          order_item_count: data['orderItemCount'],
                          order_count: data['orderCount'],
                          average_unit_price: data['averageUnitPrice']['amount'],
                          average_unit_price_currency: data['averageUnitPrice']['currencyCode'],
                          total_sales: data['totalSales']['amount'],
                          total_sales_currency: data['totalSales']['currencyCode'])
    else
      ProductSale.create(product_id: prd.id,
                         kind:,
                         month_refference: data_reference.strftime('%B'),
                         week_refference: week_of_month,
                         year_refference: Date.today.year,
                         interval: date_range,
                         unit_count: data['unitCount'],
                         order_item_count: data['orderItemCount'],
                         order_count: data['orderCount'],
                         average_unit_price: data['averageUnitPrice']['amount'],
                         average_unit_price_currency: data['averageUnitPrice']['currencyCode'],
                         total_sales: data['totalSales']['amount'],
                         total_sales_currency: data['totalSales']['currencyCode'])
    end
  end

  def obtain_acess_token
    token_params = {
      grant_type: 'refresh_token',
      refresh_token: ENV['REFRESH_TOKEN'],
      client_id: ENV['LWA_APP_ID'],
      client_secret: ENV['LWA_CLIENT_SECRET']
    }
    token_response = HTTParty.post(ENV['TOKEN_URI'], body: token_params)
    JSON.parse(token_response.body)['access_token']
  end
end
