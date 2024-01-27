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

    lines[1..].map do |line|
      values = line.split("\t")
      listing_id = values[header.index('item-name')]
      data_hash = {}

      header.each_with_index do |key, index|
        data_hash[key] = values[index]
      end

      [listing_id, data_hash]
    end
  end

  def create_update_products(result_hash)
    result_hash.each do |data|
      product = Product.find_or_create_by(id_product: data[1]['seller-sku'])
      product.update(
        item_name: data[1]['item-name'],
        item_description: data[1]['item-description'],
        listing_id: data[1]['listing-id'],
        seller_sku: data[1]['seller-sku'],
        price: data[1]['price'],
        quantity: data[1]['quantity'],
        product_id_type: data[1]['product-id-type'],
        asin1: data[1]['asin1'],
        asin2: data[1]['asin2'],
        asin3: data[1]['asin3'],
        fulfillment_channel: (data[1]['fulfillment-channel'] == 'DEFAULT' ? 'FBM' : 'FBA'),
        id_product: data[1]['product-id'],
        status: data[1]['status']
      )
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
