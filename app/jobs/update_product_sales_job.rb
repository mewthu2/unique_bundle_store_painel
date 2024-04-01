class UpdateProductSalesJob < ActiveJob::Base
  def perform(kind)
    @access_token = obtain_acess_token

    update_product_sales_info(kind)
  end

  def update_product_sales_info(kind)
    return unless ['seven_days', 'thirty_days'].include?(kind)

    products = Product.where(status: 'Active')

    total = products.count

    week_of_month = (Date.today.day + Date.today.beginning_of_month.wday - 1) / 7

    thirty_days_products = ProductSale.where(month_refference: Date.today.strftime('%B'),
                                             year_refference: Date.today.year,
                                             kind:)
    seven_days_products = ProductSale.where(month_refference: Date.today.strftime('%B'),
                                            year_refference: Date.today.year,
                                            week_refference: week_of_month,
                                            kind:)

    return if thirty_days_products.count == total && kind == 'thirty_days'

    return if seven_days_products.count == total && kind == 'seven_days'

    start_date = (Date.today - (kind == 'thirty_days' ? 30 : 7)).strftime('%Y-%m-%dT00:00:00Z')
    end_date = Date.today.strftime('%Y-%m-%dT%H:%M:%SZ')
    date_range = "#{start_date}--#{end_date}"

    resolve_products = case kind
                       when 'seven_days' then seven_days_products
                       when 'thirty_days' then thirty_days_products
                       else products
                       end

    select = products
    select = select.where.not(id: resolve_products.joins(:product).pluck(:product_id)) if resolve_products.present?

    select.each do |prd|
      p('sleeping for 1 seconds...')
      sleep(1.seconds)

      request_params = {
        granularity: 'total',
        interval: date_range,
        marketplaceIds: ENV['MARKETPLACE_ID'],
        asin: prd.asin1
      }

      endpoint = 'https://sellingpartnerapi-na.amazon.com/sales/v1/orderMetrics'

      response = HTTParty.get(endpoint, query: request_params,
                                        headers: { 'x-amz-access-token' => @access_token })
      data = response['payload']&.first

      next unless response['payload'].present?

      ProductSale.find_or_create_by(product_id: prd.id,
                                    kind:,
                                    month_refference: Date.today.strftime('%B'),
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

  private

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
