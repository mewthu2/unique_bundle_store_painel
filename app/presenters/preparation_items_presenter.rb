class PreparationItemsPresenter < SimpleDelegator
  def items
    "<table class='table table-dark table-bordered table-striped' style='overflow-x: scroll;'>
      <thead>
        <tr>
          <th class='text-center'>Quantidade</th>
          <th class='text-center'>Nome</th>
          <th class='text-center'>Status</th>
        </tr>
      </thead>
      <tbody>
        #{preparation_items.map do |e|
          "<tr>
            <td class='text-center'><span class='badge bg-light text-primary'>#{e.quantity} x</span></td>
            <td class='text-center'><span class='badge bg-primary'>#{e.product.item_name} #{e.product.seller_sku}</span></td>
            <td class='text-center'><span class='badge bg-#{e.kind == 'pending' ? 'warning text-dark' : 'success'}'>#{e.kind}</span></td>
          </tr>"
        end.join}
      </tbody>
      <tfoot>
        <tr>
          <th colspan='3'></th>
        </tr>
      </tfoot>
    </table>".html_safe
  end
end