module Amazon
  class Products
    def self.search_orders
      created_after = (DateTime.now - 30).iso8601
      request_params = {
        'MarketplaceIds' => ENV['MARKETPLACE_ID'],
        'CreatedAfter' => created_after
      }

      orders_uri = "#{ENV['ENDPOINT_AMAZON']}/orders/v0/orders"
      HTTParty.get(orders_uri, query: request_params, headers: { 'x-amz-access-token' => access_token })
    end

    def self.task_relatory
      report_type = 'GET_FLAT_FILE_OPEN_LISTINGS_DATA'
      data_start_time = '2019-12-10T20:11:24.000Z'
      marketplace_ids = [ENV['MARKETPLACE_ID']]

      report_params = {
        'reportType' => report_type,
        'dataStartTime' => data_start_time,
        'marketplaceIds' => marketplace_ids
      }

      reports_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/reports"
      HTTParty.post(reports_uri, body: report_params.to_json, headers: { 'Content-Type' => 'application/json', 'x-amz-access-token' => access_token })
    end

    def self.view_relatory(report_document_id)
      documents_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/documents/#{report_document_id}"
      documents_response = HTTParty.get(documents_uri, headers: { 'x-amz-access-token' => access_token })
      api_response = HTTParty.get(documents_response['url'])
      parse_data(api_response)
    end

    def self.verify_done_relatory(report_id)
      reports_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/reports/#{report_id}"
      reports_response = HTTParty.get(reports_uri, headers: { 'x-amz-access-token' => access_token })
      view_relatory(reports_response['reportDocumentId']) if reports_response['processingStatus'] == 'DONE'
    end

    def parse_data(api_response)
      lines2 = api_response.split("\n")

      header2 = lines_2.first.split("\t")

      result_hash = {}

      lines2[1..].each do |line|
        values2 = line.split("\t")
        listing_id = values_2[header_2.index('sku')]
        datahash2 = {}

        header2.each_with_index do |key, index|
          datahash2[key] = values2[index]
        end

        result_hash[listing_id] = data_hash_2
      end
    end

    def self.inventory_sku_fba
      token_params = {
        grant_type: 'refresh_token',
        refresh_token: ENV['REFRESH_TOKEN'],
        client_id: ENV['LWA_APP_ID'],
        client_secret: ENV['LWA_CLIENT_SECRET']
      }

      # Obtendo o token de acesso
      token_response = HTTParty.post(ENV['TOKEN_URI'], body: token_params)
      access_token = JSON.parse(token_response.body)['access_token']

      # Parâmetros para a requisição GET
      request_params = {
        details: true,
        granularityType: 'Marketplace',
        granularityId: ENV['MARKETPLACE_ID'],
        sellerSkus: 'VN-CBPG-JD21',
        marketplaceIds: ENV['MARKETPLACE_ID']
      }

      # Construindo a URI da requisição
      inventory_uri = "#{ENV['ENDPOINT_AMAZON']}/fba/inventory/v1/summaries"

      # Fazendo a requisição GET
      HTTParty.get(
        inventory_uri,
        query: request_params,
        headers: { 'x-amz-access-token' => access_token }
      )
    end

    def self.inventory_summaries
      token_params = {
        grant_type: 'refresh_token',
        refresh_token: ENV['REFRESH_TOKEN'],
        client_id: ENV['LWA_APP_ID'],
        client_secret: ENV['LWA_CLIENT_SECRET']
      }
      token_response = HTTParty.post(ENV['TOKEN_URI'], body: token_params)
      access_token = JSON.parse(token_response.body)['access_token']

      inventory_uri = "#{ENV['ENDPOINT_AMAZON']}/fba/inventory/v1/summaries"

      request_params = {
        details: true,
        pagination: '2',
        granularityType: 'Marketplace',
        granularityId: ENV['MARKETPLACE_ID'],
        marketplaceIds: ENV['MARKETPLACE_ID']
      }

      HTTParty.get(
        inventory_uri,
        query: request_params,
        headers: { 'x-amz-access-token' => access_token }
      )
    end

    def self.inventory_summaries_with_start_date
      token_params = {
        grant_type: 'refresh_token',
        refresh_token: ENV['REFRESH_TOKEN'],
        client_id: ENV['LWA_APP_ID'],
        client_secret: ENV['LWA_CLIENT_SECRET']
      }
      token_response = HTTParty.post(token_uri, body: token_params)
      access_token = JSON.parse(token_response.body)['access_token']

      inventory_uri = "#{ENV['ENDPOINT_AMAZON']}/fba/inventory/v1/summaries"
      start_date = '2018-03-27T23:40:39Z'
      request_params = {
        granularityType: 'Marketplace',
        granularityId: ENV['MARKETPLACE_ID'],
        startDateTime: start_date,
        marketplaceIds: ENV['MARKETPLACE_ID']
      }

      HTTParty.get(
        inventory_uri,
        query: request_params,
        headers: { 'x-amz-access-token' => access_token }
      )
    end

    # fonte: https://developer-docs.amazon.com/sp-api/docs/sales-api-v1-use-case-guide
    def self.search_order_metrics
      Product.all.each do |prd|
        p('dormindo 2 segundos')
        sleep(2.seconds)
        p('acordei')
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
        response = HTTParty.get(order_metrics_uri, query: request_params, headers: { 'x-amz-access-token' => access_token })

        parsed_response = JSON.parse(response.body)

        total_unit_count = 0
        total_sales_amount = 0.0

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

    def update_fba_products
      Product.where(fulfillment_channel: 'FBA').each do |pfba|
        p('dormindo 2 segundos')
        sleep(2.seconds)
        p('acordei - bora atualizar esses fba brabo')
        request_params = {
          details: true,
          granularityType: 'Marketplace',
          granularityId: ENV['MARKETPLACE_ID'],
          sellerSkus: pfba.seller_sku.to_s,
          marketplaceIds: ENV['MARKETPLACE_ID']
        }

        inventory_uri = "#{ENV['ENDPOINT_AMAZON']}/fba/inventory/v1/summaries"

        response = HTTParty.get(
          inventory_uri,
          query: request_params,
          headers: { 'x-amz-access-token' => access_token }
        )

        pfba.update(pending_customer_order_quantity: response['payload']['inventorySummaries'][0]['inventoryDetails']['reservedQuantity']['pendingCustomerOrderQuantity'],
                    quantity: response['payload']['inventorySummaries'][0]['totalQuantity'])
      end
    end

    def resolver_stock
      Product.all.each do |product|
        a = product.total_unit_count.to_i
        b = product.pending_customer_order_quantity.to_i
        c = product.quantity.to_i
        product.update(resolver_stock: a - b - c)
      end
    end

    def create_products(result_hash)
      result_hash.each do |ap|
        if product == Product.find_by(id_product: ap[1]['product-id'])
          product.update(item_name: ap[1]['item-name'],
                         item_description: ap[1]['item-description'],
                         listing_id: ap[1]['listing-id'],
                         seller_sku: ap[1]['seller-sku'],
                         price: ap[1]['price'],
                         quantity: ap[1]['quantity'],
                         product_id_type: ap[1]['product-id-type'],
                         asin1: ap[1]['asin1'],
                         asin2: ap[1]['asin2'],
                         asin3: ap[1]['asin3'],
                         fulfillment_channel: ap[1]['fulfillment-channel'] == 'DEFAULT' ? 'FBM' : 'FBA',
                         id_product: ap[1]['product-id'],
                         status: ap[1]['status'])
        else
          Product.find_or_create_by!(item_name: ap[1]['item-name'],
                                     item_description: ap[1]['item-description'],
                                     listing_id: ap[1]['listing-id'],
                                     seller_sku: ap[1]['seller-sku'],
                                     price: ap[1]['price'],
                                     quantity: ap[1]['quantity'],
                                     product_id_type: ap[1]['product-id-type'],
                                     asin1: ap[1]['asin1'],
                                     asin2: ap[1]['asin2'],
                                     asin3: ap[1]['asin3'],
                                     fulfillment_channel: ap[1]['fulfillment-channel'] == 'DEFAULT' ? 'FBM' : 'FBA',
                                     id_product: ap[1]['product-id'],
                                     status: ap[1]['status'])
        end
      end
    end
  end
end
