class DashboardController < ApplicationController
  before_action :load_references, only: [:index, :generate_spreadsheet]

  def index; end

  def generate_spreadsheet
    send_data(GenerateSpreadsheetJob.perform_now(@products),
              disposition: %(attachment; filename=products_unique_#{DateTime.now}.xlsx))
  end

  private

  def load_references
    @products = Product.search(params[:search])
                       .by_fulfillment_channel(params[:fulfillment_channel])
                       .by_status(params[:status])
                       .by_active(params[:active])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end
end
