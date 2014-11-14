class OrderController < Spree::StoreController
  layout "application"
  include Spree::Core::ControllerHelpers::Order
  helper 'spree/orders'
  rescue_from Spree::Core::GatewayError, :with => :rescue_from_spree_gateway_error

  def checkout
    @order = Spree::Order.new(:user_id => spree_current_user.id, :created_by_id => spree_current_user.id)
    @order.state = "address"
    @order.save

      @product = Spree::Product.find(params[:product])
      @heart = @order.line_items.new(:variant_id => params[:product], :quantity => params[:quantity], :price => @product.price)
      @heart.save

    @order.update_attributes(:item_total => @order.amount)
    render :json => {:result => "success" } 
  end

  def address
    @order = Spree::Order.where(:user_id => spree_current_user.id, :state => "address").last
    @order.bill_address ||= Spree::Address.default(try_spree_current_user, "bill")
    if @order.checkout_steps.include? "address"
      @order.ship_address ||= Spree::Address.default(try_spree_current_user, "ship")
    end
  end

  def ship
    if spree_current_user.present?
      @order = Spree::Order.where(:user_id => spree_current_user.id, :state => "address").last
    end
    # Luu thong tin address
    flow(@order)
    @order.state = "payment"
    @order.save
    render :json => {:result => "success" } 
  end

  def payment
    if spree_current_user.present?
      @order = Spree::Order.where(:user_id => spree_current_user.id, :state => "payment").last
    end
    #Truoc khi payment
    if @order.checkout_steps.include? "payment"
      packages = @order.shipments.map { |s| s.to_package }
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      @differentiator.missing.each do |variant, quantity|
        @order.contents.remove(variant, quantity)
      end
    end
    if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
      @payment_sources = try_spree_current_user.payment_sources
    end
  end

  def complete
    @order = Spree::Order.where(:user_id => spree_current_user.id, :state => "payment").last
    #State = Payment
    flow(@order)
    #State = confirm
    flow(@order)
    render :json => {:result => "success"}
  end

  private

  def flow order
    if order.update_from_params(params, permitted_checkout_attributes)
      unless @order.next
      flash[:error] = order.errors.full_messages.join("\n")
      end
      if order.completed?
        current_order = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
      end
    end
  end 
  def ensure_valid_state
    unless skip_state_validation?
      if (params[:state] && !@order.has_checkout_step?(params[:state])) ||
        (!params[:state] && !@order.has_checkout_step?(@order.state))
        @order.state = 'cart'
        redirect_to checkout_state_path(@order.checkout_steps.first)
      end
    end

        # Fix for #4117
        # If confirmation of payment fails, redirect back to payment screen
    if params[:state] == "confirm" && @order.payment_required? && @order.payments.valid.empty?
          flash.keep
          redirect_to checkout_state_path("payment")
        end
      end

      # Should be overriden if you have areas of your checkout that don't match
      # up to a step within checkout_steps, such as a registration step
  def skip_state_validation?
        false
      end

      def load_order_with_lock
        @order = current_order(lock: true)
        redirect_to spree.cart_path and return unless @order

        if params[:state]
          redirect_to checkout_state_path(@order.state) if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
          @order.state = params[:state]
        end
      end

      def ensure_checkout_allowed
        unless @order.checkout_allowed?
          redirect_to spree.cart_path
        end
      end

      def ensure_order_not_completed
        redirect_to spree.cart_path if @order.completed?
      end

      def ensure_sufficient_stock_lines
        if @order.insufficient_stock_lines.present?
          flash[:error] = Spree.t(:inventory_error_flash_for_insufficient_quantity)
          redirect_to spree.cart_path
        end
      end

      # Provides a route to redirect after order completion
      def completion_route
        spree.order_path(@order)
      end

      def setup_for_current_state
        method_name = :"before_#{@order.state}"
        send(method_name) if respond_to?(method_name, true)
      end

      # Skip setting ship address if order doesn't have a delivery checkout step
      # to avoid triggering validations on shipping address
      def before_address
        @order.bill_address ||= Address.default(try_spree_current_user, "bill")

        if @order.checkout_steps.include? "delivery"
          @order.ship_address ||= Address.default(try_spree_current_user, "ship")
        end
      end

      def before_delivery
        return if params[:order].present?

        packages = @order.shipments.map { |s| s.to_package }
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
      end

      def before_payment
        if @order.checkout_steps.include? "delivery"
          packages = @order.shipments.map { |s| s.to_package }
          @differentiator = Spree::Stock::Differentiator.new(@order, packages)
          @differentiator.missing.each do |variant, quantity|
            @order.contents.remove(variant, quantity)
          end
        end

        if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
          @payment_sources = try_spree_current_user.payment_sources
        end
      end

      def rescue_from_spree_gateway_error(exception)
        flash.now[:error] = Spree.t(:spree_gateway_error_flash_for_checkout)
        @order.errors.add(:base, exception.message)
        render :edit
      end

      def check_authorization
        authorize!(:edit, current_order, cookies.signed[:guest_token])
      end

      def persist_user_address
        if @order.checkout_steps.include? "address"
          if @order.address? && try_spree_current_user.respond_to?(:persist_order_address)
            try_spree_current_user.persist_order_address(@order) if params[:save_user_address]
          end
        end
      end

end
