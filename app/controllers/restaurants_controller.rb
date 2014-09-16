class RestaurantsController < ApplicationController
	before_action :load_restaurant, only: [:show, :edit, :update, :destroy]

	def index
			@restaurants = if params[:search]
				Restaurant.where('LOWER(name) LIKE LOWER(?)', '%#{params[:search]}%')
			else
				Restaurant.all 
			end

			if request.xhr?
				render @restaurants
			end
		end

		def show
			@reservation = Reservation.new
			@customer = Customer.find(session[:customer_id]) if session[:customer_id]

			if current_user
				@review = @restaurant.reviews.build
			end
		end

		def new
			@restaurant = Restaurant.new
		end

		def create
			@restaurant = Restaurant.new(restaurant_params)
			@restaurant.capacity = 100

			if @restaurant.save
				session[:restaurant_id] = @restaurant.id
				redirect_to restaurant_path(@restaurant), notice: "Let's make some food"
			else
				render :new, alert: "Something went wrong!!"
			end
		end

		def edit
		end

		def update
			if @restaurant.update(restaurant_params)
				redirect_to restaurant_path(@restaurant), notice: "Profile updated."
			else
				render :edit, alert: "Something went wrong!!"
			end
		end

		def search
			if params[:location].present?
				@restaurants = Restaurant.near(params[:location], params[:distance] ||= 10, order: "distance asc")
			else
				@restaurants = Restaurant.search(params[:search]).order("name ASC")
			end
		end

		def destroy
			session[:restaurant_id] = nil
			@restaurant.destroy
			redirect_to root_path, notice: "Sad to see you go!" 
		end

		private

	def restaurant_params
		params.require(:restaurant).permit(:name, :email, :password, :password_confirmation, :address, :city, :province, :postal_code, :description, :area_code, :phone_prefix, :phone_suffix, :attachment, :food_type_ids => [])
	end

		def load_restaurant
			@restaurant = Restaurant.find(params[:id])
		end
	end
