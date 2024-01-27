class UpdateProductsMetricsJob < ActiveJob::Base
  def perform
    # STEP1=obtain acess token
    @access_token = obtain_acess_token
    # STEP6=obtain last 30 days sells
    search_order_metrics
  end

  def search_order_metrics
    Product.all.each do |prd|
      p('sleeping for 500 mili seconds...')
      sleep(0.5.seconds)
      p('i woke up, give me a time on saturday ok? 100km again? lets go!, search_order_metrics')
      end_date = DateTime.now
      start_date = end_date - 29

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

      next unless parsed_response['payload'].present?

      parsed_response['payload'].each do |item|
        total_unit_count += item['unitCount']
        total_sales_amount += item['totalSales']['amount'].to_f
      end

      prd.update(total_unit_count:, total_sales_amount:)
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
