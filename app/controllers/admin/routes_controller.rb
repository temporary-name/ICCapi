module Admin
  class RoutesController < ApplicationController
    helper_method :sort_column, :sort_direction
    before_action :find_route, only: [:edit, :update, :destroy]
    before_action :find_setters, only: [:new, :create, :edit, :update]

    def index
      @routes = Route.joins(:user).active_routes
      @routes = @routes.with_full_text_search(params[:search]) if params[:search].present?
      @routes = @routes.order(sort_column + " " + sort_direction)
      @routes = @routes.page(params[:page])
    end

    def show
      @route = Route.includes(comments: :user).find(params[:id])
      @request = MaintenanceRequest.new
      @comment = Comment.new
      @comments = @route.comments.most_recent

      @user_rating = Rating.get_user_rating(@route.id, current_user.id)
      @rating = Rating.get_rating(@route.id)
    end

    def new
      authorize Route.new
      @form = RouteForm.new
    end

    def edit
      @form = RouteForm.new(@route)
    end

    def create
      authorize Route.new
      @form = RouteForm.new

      if @form.submit(route_params)
        flash[:success] = "Successfully created route."
        redirect_to controller: "admin/routes", action: "index"
      else
        render :new
      end
    end

    def update
      @form = RouteForm.new(@route)

      if @form.submit(route_params)
        flash[:success] = "Successfully updated route."
        redirect_to [:admin, @form]
      else
        render :edit
      end
    end

    def destroy
      @route.status = "inactive"
      @route.label = nil
      if @route.save
        flash[:success] = "Successfully disabled route."
        redirect_to controller: "admin/routes", action: "index"
      else
        flash[:danger] = "Could not disable route."
        render :show
      end
    end

    private

    def route_params
      params.require(:route).permit(
        :name, :user_id, :label, :location, :tape_color, :route_set_date, :status,
        :grade, :description, :image_1, :image_2
      )
    end

    def find_setters
      @setters = User.setters
    end

    def find_route
      @route = Route.find(params[:id])
      authorize @route
    end

    def sort_column
      whitelist = %w(label name users.first_name location tape_color grade route_set_date expiration_date)
      whitelist.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w(asc desc).include?(params[:direction]) ?  params[:direction] : "asc"
    end
  end
end
