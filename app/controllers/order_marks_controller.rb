class OrderMarksController < ApplicationController
  before_action :set_order_mark, only: [:show, :edit, :update, :destroy]

  # GET /order_marks
  def index; end

  # GET /order_marks/1/edit
  def edit; end

  # POST /order_marks
  def create
    @order_mark = OrderMark.new(order_mark_params)

    if @order_mark.save
      redirect_to order_marks_path, notice: 'Marcação de ordem criada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /order_marks/1
  def update
    if @order_mark.update(order_mark_params)
      redirect_to order_marks_path, notice: 'Marcação de ordem atualizada com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /order_marks/1
  def destroy
    @order_mark.destroy
    redirect_to order_marks_path, notice: 'Marcação de ordem excluída com sucesso.'
  end

  private

  # Set order_mark by ID
  def set_order_mark
    @order_mark = OrderMark.find(params[:id])
  end

  # It allows only useful parameters.
  def order_mark_params
    params.require(:order_mark)
          .permit(:amazon_order_id,
                  :bought)
  end
end
