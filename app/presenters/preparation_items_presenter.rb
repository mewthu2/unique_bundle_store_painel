class PreparationItemsPresenter < SimpleDelegator
  def items
    preparation_items.map { |e| "<span class='badge bg-light text-primary'>#{e.quantity} x</span> 
                                 <span class='badge bg-primary'>#{e.product.item_name } #{e.product.seller_sku } </span>
                                 <span class='badge bg-#{e.kind == 'pending' ? 'warning text-dark' : 'success'}'>#{e.kind } </span>" }.join(', ').html_safe
  end
end