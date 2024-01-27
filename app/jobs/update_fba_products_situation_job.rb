class UpdateFbaProductsSituationJob < ActiveJob::Base
  def perform
    # STEP1=obtain acess token
    @access_token = obtain_acess_token
    # STEP7=update_fba_products situation
    update_fba_products
    # STEP8=calculate formula (30_days_sell_quantity - pending_customer - stock_quantity)
    resolver_stock
  end

  def update_fba_products
    Product.where(fulfillment_channel: 'FBA').each do |pfba|
      p('sleeping a couple... 500 mili second')
      sleep(0.5.seconds)
      p('i woke up, omg this shits never ends, updating attributes of fba products')
      request_params = {
        details: true,
        granularityType: 'Marketplace',
        granularityId: ENV['MARKETPLACE_ID'],
        sellerSkus: pfba.seller_sku,
        marketplaceIds: ENV['MARKETPLACE_ID']
      }

      inventory_uri = "#{ENV['ENDPOINT_AMAZON']}/fba/inventory/v1/summaries"

      response = HTTParty.get(
        inventory_uri,
        query: request_params,
        headers: { 'x-amz-access-token' => @access_token }
      )
      next unless response['payload'].present?

      pfba.update(pending_customer_order_quantity: response['payload']['inventorySummaries'][0]['inventoryDetails']['reservedQuantity']['pendingCustomerOrderQuantity'],
                  quantity: response['payload']['inventorySummaries'][0]['totalQuantity'])
    end
  end

  def resolver_stock
    Product.all.each do |product|
      a = product.total_unit_count.to_i
      b = product.pending_customer_order_quantity.to_i
      c = product.quantity.to_i
      totalx = b - c
      product.update(resolver_stock: a + totalx)
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