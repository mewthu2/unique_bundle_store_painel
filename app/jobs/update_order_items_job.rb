class UpdateOrderItemsJob < ApplicationJob
  def perform
    update_order_items
  end

  def update_order_items
    orders = []
    next_token = nil

    loop do
      response = SearchOrderStatusJob.perform_now('MFN', next_token, '')
      orders += response['payload']['Orders'].map { |order| order['AmazonOrderId'] }
      next_token = response['payload']['NextToken']

      break unless next_token
    end

    orders.each do |order|
      order_item_data = SearchOrderStatusJob.perform_now('MFN', '', order)
      order_item_data['payload']['OrderItems'].each do |order_item|
        product = Product.find_by(seller_sku: order_item['SellerSKU'])
        next unless product.present?
        next if OrderItem.find_by(amazon_order_id: order)

        p('Descansando pra Amazon não tilta')
        sleep(2.seconds)
        p('Tankaste feminha')

        OrderItem.find_or_create_by(product_id: product.id, amazon_order_id: order, quantity: order_item['QuantityOrdered'])
      end
    end
  end
end
