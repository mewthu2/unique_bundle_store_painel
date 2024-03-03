class OrderItemsPresenter < SimpleDelegator
  def items
    order = SearchOrderStatusJob.perform_now('MFN', '', self['AmazonOrderId'])
    order['OrderItems']&.first&['SellerSKU']
  end
end