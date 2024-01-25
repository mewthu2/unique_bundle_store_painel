class DashboardController < ApplicationController
  def index
    @products = Product.search(params[:search])
                       .see_rules(params[:all])
                       .by_fulfillment_channel(params[:fulfillment_channel])
                       .by_status(params[:status])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end
end
