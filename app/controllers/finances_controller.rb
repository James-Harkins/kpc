class FinancesController < ApplicationController
  def index
    if current_user
      if current_user.admin?
        @next_trip = Trip.find(params[:trip_id])
      else
        redirect_to "/dashboard"
        flash[:login] = "Admins only, Fucko!"
      end
    else 
      redirect_to "/login"
      flash[:login] = "Log in first, Fucko!"
    end
  end
end
