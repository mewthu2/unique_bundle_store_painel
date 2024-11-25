class MainStoreUpdateJob < ActiveJob::Base
  def perform
    # STEP 1: Obter access token
    @access_token = obtain_access_token

    # STEP 2: Solicitar relatório para obter dados dos produtos
    report_task = task_report

    # STEP 3: Verificar se o relatório está pronto
    report_status = verify_report_done(report_task['reportId'])

    # STEP 4: Consultar e processar relatório, se concluído
    if report_status['processingStatus'] == 'DONE'
      report_data = view_report(report_status['reportDocumentId'])
      # STEP 5: Criar/atualizar produtos com os dados do relatório
      create_update_products(report_data)
    else
      Rails.logger.error("Relatório não está pronto. Status: #{report_status['processingStatus']}")
    end
  end

  private

  def task_report
    report_type = 'GET_MERCHANT_LISTINGS_ALL_DATA'
    data_start_time = '2020-12-10T20:11:24.000Z'
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

  def verify_report_done(report_id)
    reports_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/reports/#{report_id}"

    loop do
      response = HTTParty.get(reports_uri, headers: { 'x-amz-access-token' => @access_token })
      return response if response['processingStatus'] == 'DONE'

      Rails.logger.info('Relatório ainda não concluído. Aguardando 10 segundos antes de verificar novamente...')
      sleep(10)
    end
  end

  def view_report(report_document_id)
    documents_uri = "#{ENV['ENDPOINT_AMAZON']}/reports/2021-06-30/documents/#{report_document_id}"
    documents_response = HTTParty.get(documents_uri, headers: { 'x-amz-access-token' => @access_token })

    api_response = HTTParty.get(documents_response['url'])

    gzip_content = StringIO.new(api_response.body)
    uncompressed_content = Zlib::GzipReader.new(gzip_content).read

    utf8_content = uncompressed_content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

    parse_data(utf8_content)
  end

  def parse_data(uncompressed_content)
    lines = uncompressed_content.split("\n")
    header = lines.first.split("\t")

    lines[1..].map do |line|
      values = line.split("\t")
      listing_id = values[header.index('item-name')]

      data_hash = {}
      header.each_with_index { |key, index| data_hash[key] = values[index] }

      [listing_id, data_hash]
    end
  end

  def create_update_products(parsed_data)
    parsed_data.each do |data|
      product = Product.find_or_create_by(seller_sku: data[1]['seller-sku'])
      product.update_columns(
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
        fulfillment_channel: data[1]['fulfillment-channel'] == 'DEFAULT' ? 'FBM' : 'FBA',
        id_product: data[1]['product-id'],
        status: data[1]['status']
      )
    end
  end

  def obtain_access_token
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
