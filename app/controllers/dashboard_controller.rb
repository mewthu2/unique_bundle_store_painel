class DashboardController < ApplicationController
  before_action :load_references, only: [:index, :generate_spreadsheet]

  def index; end

  def generate_spreadsheet
    send_data(GenerateSpreadsheetJob.perform_now(@products),
              disposition: %(attachment; filename=products_unique_#{DateTime.now}.xlsx))
  end

  private

  def load_references
    @products = Product.left_joins(:preparation_items)
                       .select('products.*,
                                preparation_items.*,
                                preparation_items.quantity as quantity_preparation,
                                products.id as id,
                                products.updated_at as updated_at')
                       .search(params[:search])
                       .by_fulfillment_channel(params[:fulfillment_channel])
                       .by_status(params[:status])
                       .by_active(params[:active])
  end
end
