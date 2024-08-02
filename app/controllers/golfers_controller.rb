class GolfersController < ApplicationController
  def show
    @golfer = current_user
  end

  def new
  end

  def create
    golfer = Golfer.new(golfer_params)
    if golfer.save
      redirect_to "/login"
    else
      redirect_to "/register"
      flash[:error] = golfer.errors.full_messages.to_sentence + ", fucko!"
    end
  end

  def golfer_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
