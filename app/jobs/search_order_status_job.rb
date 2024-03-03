class SearchOrderStatusJob < ApplicationJob
  def perform(order_kind, next_token)
    @access_token = obtain_acess_token
    search(order_kind, next_token)
  end

  def search(order_kind, next_token)
    created_after_date = '2023-12-10'

    request_params = {
      MarketplaceIds: ENV['MARKETPLACE_ID'],
      CreatedAfter: created_after_date,
      OrderStatuses: 'Unshipped',
      FulfillmentChannels: order_kind.to_s,
      NextToken: next_token.to_s
    }

    order_uri = "#{ENV['ENDPOINT_AMAZON']}/orders/v0/orders"

    HTTParty.get(order_uri, query: request_params,
                            headers: { 'x-amz-access-token' => @access_token })
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