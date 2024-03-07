class UpdateProductsMetricsJob < ActiveJob::Base
  def perform(days_param, fulfillment_channel)
    # STEP1=obtain acess token
    @access_token = obtain_acess_token
    # STEP6=obtain last 30 days sells
    search_order_metrics(days_param, fulfillment_channel)
  end

  def search_order_metrics(days, fulfillment_channel)
    products = Product.where(status: 'Active', fulfillment_channel:)

    @total = products.count

    products.each_with_index do |prd, index|
      p('sleeping for 2 seconds...')
      sleep(2.seconds)
      puts("Processando produto #{index + 1} de #{@total}: #{prd.id}")
      end_date = DateTime.now
      start_date = end_date - days

      formatted_start_date = start_date.iso8601
      formatted_end_date = end_date.iso8601

      request_params = {
        'marketplaceIds' => ENV['MARKETPLACE_ID'],
        'interval' => "#{formatted_start_date}--#{formatted_end_date}",
        'granularity' => 'day',
        'sku' => prd.seller_sku
      }

      order_metrics_uri = "#{ENV['ENDPOINT_AMAZON']}/sales/v1/orderMetrics"
      response = HTTParty.get(order_metrics_uri, query: request_params,
                                                 headers: { 'x-amz-access-token' => @access_token })

      parsed_response = JSON.parse(response.body)

      total_unit_count = 0
      total_sales_amount = 0.0

      parsed_response['payload'].each do |item|
        total_unit_count += item['unitCount']
        total_sales_amount += item['totalSales']['amount'].to_f
      end
      if days == 6
        prd.update_columns(total_unit_count_7: total_unit_count, total_sales_amount_7: total_sales_amount)
      else
        prd.update_columns(total_unit_count:, total_sales_amount:)
      end
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
