class UpdateProductSalesJob < ActiveJob::Base
  def perform(kind)
    @access_token = obtain_acess_token

    update_product_sales_info(kind)
  end

  def update_product_sales_info(kind)
    case kind
    when 'thirty_days'
      update_thirty_days_sales(kind)
    end
  end

  def update_thirty_days_sales(kind)
    products = Product.where(status: 'Active')

    data_refference = Date.today.prev_month - 60.day

    start_date = data_refference.beginning_of_month.strftime('%Y-%m-%dT00:00:00Z')
    end_date = data_refference.strftime('%Y-%m-%dT%H:%M:%SZ')
    date_range = "#{start_date}--#{end_date}"

    products.each do |prd|
      next if ProductSale.where(product_id: prd.id, month_refference: data_refference.strftime('%B'), year_refference: Date.today.year, kind:).present?

      p('sleeping for 1 seconds...')
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

      update_or_create_product_sale(prd, nil, date_range, data, kind, data_refference)
    end
  end

  private

  def update_or_create_product_sale(prd, week_of_month, date_range, data, kind, data_refference)
    ProductSale.find_or_create_by(product_id: prd.id,
                                  kind:,
                                  month_refference: data_refference.strftime('%B'),
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
