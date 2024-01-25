class UpdateProductsSituationJob < ActiveJob::Base
  def perform
    # STEP1=obtain acess token
    @access_token = obtain_acess_token
    # STEP2=task a relatory to obtain products data
    task_relatory
    # STEP3=verify if relatory is ready
    verify = verify_done_relatory(task_relatory['reportId'])
    # STEP4=consult relatory and parse them
    relatory = view_relatory(verify['reportDocumentId']) if verify['processingStatus'] == 'DONE'
    # STEP5=create/update product and fbm situations/quantity and another fields
    create_update_products(relatory)
    # STEP6=obtain last 30 days sells
    search_order_metrics
    # STEP7=update_fba_products situation
    update_fba_products
    # STEP8=calculate formula (30_days_sell_quantity - pending_customer - stock_quantity)
    resolver_stock
  end

  def task_relatory
    report_type = 'GET_MERCHANT_LISTINGS_ALL_DATA'
    data_start_time = '2019-12-10T20:11:24.000Z'
    marketplace_ids = [ENV['MARKETPLACE_ID']]

    report_params = {
      'reportType' => report_type,
      'dataStartTime' => data_start_time,
      'marketplaceIds' => marketplace_ids
    }

    reports_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/reports"
    HTTParty.post(reports_uri, body: report_params.to_json,
                               headers: { 'Content-Type' => 'application/json',
                                          'x-amz-access-token' => @access_token })
  end

  def verify_done_relatory(report_id)
    reports_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/reports/#{report_id}"

    loop do
      status = HTTParty.get(reports_uri, headers: { 'x-amz-access-token' => @access_token })
      return status if status['processingStatus'] == 'DONE'

      p(status.body)
      p('Relatório ainda não concluído. Aguardando 10 segundos antes de verificar novamente...')
      sleep(5)
    end
  end

  def view_relatory(report_document_id)
    documents_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/documents/#{report_document_id}"
    documents_response = HTTParty.get(documents_uri, headers: { 'x-amz-access-token' => @access_token })
    api_response = HTTParty.get(documents_response['url'])
    parse_data(api_response)
  end

  def parse_data(api_response)
    lines = api_response.split("\n")

    header = lines.first.split("\t")

    result_hash = {}

    lines[1..].each do |line|
      values = line.split("\t")
      listing_id = values[header.index('item-name')]
      data_hash = {}

      header.each_with_index do |key, index|
        data_hash[key] = values[index]
      end

      result_hash[listing_id] = data_hash
    end
  end

  def create_update_products(result_hash)
    result_hash.each do |data|
      product = Product.find_or_initialize_by(id_product: data['product-id'])

      product.update(
        item_name: data['item-name'],
        item_description: data['item-description'],
        listing_id: data['listing-id'],
        seller_sku: data['seller-sku'],
        price: data['price'],
        quantity: data['quantity'],
        product_id_type: data['product-id-type'],
        asin1: data['asin1'],
        asin2: data['asin2'],
        asin3: data['asin3'],
        fulfillment_channel: (data['fulfillment-channel'] == 'DEFAULT' ? 'FBM' : 'FBA'),
        id_product: data['product-id'],
        status: data['status']
      )

      product.save
    end
  end

  def search_order_metrics
    Product.all.each do |prd|
      p('sleeping for 1 second...')
      sleep(1.second)
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

      parsed_response['payload'].each do |item|
        total_unit_count += item['unitCount']
        total_sales_amount += item['totalSales']['amount'].to_f
      end

      prd.update(total_unit_count:, total_sales_amount:)
      p(prd)
    end
  end

  def update_fba_products
    Product.where(fulfillment_channel: 'FBA').each do |pfba|
      p('sleeping a couple... 1 second')
      sleep(1.second)
      p('i woke up, omg this shits never ends, updating attributes of fba products')
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
        headers: { 'x-amz-access-token' => @access_token }
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
      totalx = b - c
      product.update(resolver_stock: a - totalx)
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
