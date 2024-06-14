class OrdersController < ApplicationController
  def index
    @orders = Order.where(user_id: current_user.id).order(created_at: :desc)
  end

  def new
    @order = Order.new
    @order.ordered_lists.build #多対多のモデル。
    @items = Item.all.order(:created_at)
  end

  def create
    ActiveRecord::Base.transaction do
    #Itemの中で注文されたItemIDの商品をロックしたい
    #注文されたItemをすべて持ってきて数量が0ではないものだけをロックしたい
    @order = current_user.orders.build(order_params)
    #  selected_items = @order.ordered_lists.filter_map {|v| v.item_id if v.quantity > 0}
    #  selected_items.each do |id|
    #   item = Item.find(id)
    #   item.with_lock do
    #   end
    #binding.irb
    @order.with_lock do
    @order.save!
    @order.update_total_quantity
    # update_total_quantityメソッドは、注文された発注量を総量に反映するメソッドであり、Orderモデルに定義されています。
    end
    redirect_to orders_path
  end

  private

  def order_params
    params.require(:order).permit(ordered_lists_attributes: [:item_id, :quantity])
  end

end
